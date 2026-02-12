# Build the prometheus_varnish_exporter binary
FROM docker.io/library/golang:1.23 AS prometheus_varnish_exporter
WORKDIR /app

# Releases: https://github.com/jonnenauha/prometheus_varnish_exporter/releases
ARG PROMETHEUS_VARNISH_EXPORTER_VERSION=1.6.1

RUN git config --global advice.detachedHead false \
  && git clone https://github.com/jonnenauha/prometheus_varnish_exporter.git . \
  && git checkout "${PROMETHEUS_VARNISH_EXPORTER_VERSION}" \
  && go mod download \
  && go build -o prometheus_varnish_exporter

# Build varnish-modules from source (bodyaccess + xkey VMODs)
# These are not available in the official Varnish packagecloud repo
FROM docker.io/library/ubuntu:24.04 AS varnish_modules_builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  curl \
  gnupg \
  ca-certificates \
  apt-transport-https \
  lsb-release \
  && curl -s -o /tmp/varnish-repo.sh https://packagecloud.io/install/repositories/varnishcache/varnish76/script.deb.sh \
  && bash /tmp/varnish-repo.sh \
  && rm /tmp/varnish-repo.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  varnish \
  varnish-dev \
  automake \
  autotools-dev \
  libtool \
  make \
  gcc \
  git \
  pkg-config \
  python3-docutils \
  && git clone --branch 7.6 --depth 1 https://github.com/varnish/varnish-modules.git /tmp/varnish-modules \
  && cd /tmp/varnish-modules \
  && ./bootstrap \
  && ./configure \
  && make \
  && make install

# Build the final image
FROM docker.io/library/ubuntu:24.04

# Configuration
ENV BACKEND_HOST="localhost"
ENV BACKEND_PORT="3000"
ENV CACHE_TTL="3600s"
ENV BODY_SIZE="2048KB"
ENV BACKEND_FIRST_BYTE_TIMEOUT="60s"
ENV VARNISH_SIZE="100M"
ENV DISABLE_ERROR_CACHING="true"
ENV DISABLE_ERROR_CACHING_TTL="30s"
ENV CONFIG_FILE="default.vcl"
ENV ENABLE_LOGS="true"
ENV ENABLE_PROMETHEUS_EXPORTER="false"
ENV PURGE_ACL="localhost"
ENV CUSTOM_ARGS=""

# Install Varnish 7.6 from official packagecloud repository
# Ubuntu repos ship Varnish 7.1 which is EOL (no upstream security patches)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  gettext \
  tini \
  curl \
  gnupg \
  ca-certificates \
  apt-transport-https \
  lsb-release \
  && curl -s -o /tmp/varnish-repo.sh https://packagecloud.io/install/repositories/varnishcache/varnish76/script.deb.sh \
  && bash /tmp/varnish-repo.sh \
  && rm /tmp/varnish-repo.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends varnish \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy compiled varnish-modules (bodyaccess, xkey, etc.) from builder stage
COPY --from=varnish_modules_builder \
  /usr/lib/varnish/vmods/ \
  /usr/lib/varnish/vmods/

# Get the prometheus_varnish_exporter binary
COPY --from=prometheus_varnish_exporter \
  /app/prometheus_varnish_exporter \
  /usr/local/bin/prometheus_varnish_exporter

# Deploy our custom configuration
WORKDIR /etc/varnish
COPY config/ /templates
COPY entrypoint.sh /
# Convert line endings from Windows CRLF to Unix LF and set executable
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80 8443 9131
CMD [ "tini", "--", "/entrypoint.sh" ]
