# lindas-varnish-post Changelog

**Repository:** SwissFederalArchives/lindas-varnish-post
**Description:** Varnish cache with POST request support for SPARQL endpoints

---

## LINDAS Development (January 2026)

### 2026-01-26

**DevOps Pipeline Implementation**
- Created `develop` branch for development workflow
- Updated `docker.yaml` to build and auto-deploy to TEST on main push
- Added `deploy-test.yaml` for manual TEST environment override
- Added `deploy-int.yaml` for manual INT environment promotion
- Added `deploy-prod.yaml` for manual PROD deployment (requires approval)
- Added `rollback-test.yaml` for one-click TEST rollback
- Added `rollback-int.yaml` for one-click INT rollback
- Added `rollback-prod.yaml` for one-click PROD rollback (requires approval)
- Each environment maintains a `-previous` tag for instant rollback capability

---

## LINDAS Development (December 2025)

### 2025-12-10

**`2623e56` - Fix security vulnerability and Windows line ending issues**
- Fixed security vulnerabilities in dependencies
- Fixed Windows line ending issues for cross-platform compatibility

### 2025-10-17

**`ddbcf6e` - Add GitHub Actions build cache to Docker workflow**
- Added build caching for faster CI builds

**`50f05e0` - Add explicit permissions to Docker workflow for GHCR push**
- Fixed GitHub Container Registry permissions

**`c022583` - Fix Docker workflow trigger to build on main branch pushes**
- Fixed workflow trigger conditions

**`0b5a03e` - Fix Docker image registry name in GitHub Actions workflow**
- Fixed registry naming for LINDAS organization

---

## Original Releases

## 2.8.0

### Minor Changes

- ce9e42c: Also hash the Accept header

## 2.7.0

### Minor Changes

- 513b918: Add support for `CUSTOM_ARGS`

## 2.6.0

### Minor Changes

- d5f1065: Upgrade Ubuntu to 24.04 for the base image

## 2.5.0

### Minor Changes

- 60aa54b: It is now possible to configure purge ACL, by setting the `PURGE_ACL` to a relevant hostname or IP CIDR.

  By default, the `PURGE_ACL` is set to `localhost`.
  This means that only requests coming from the same host as the Varnish container will be able to purge the cache.

  You can set the `PURGE_ACL` to `0.0.0.0/0` to allow all hosts to purge the cache for example, or a more specific IP CIDR.

## 2.4.0

### Minor Changes

- 3db843d: Enable Prometheus Exporter by setting `ENABLE_PROMETHEUS_EXPORTER` to `true`.

## 2.3.0

### Minor Changes

- 1b8342c: Add xkey support in order to support tag-based invalidation.

  The backend can now send a `xkey` header with a value that will be used to tag the cache entry.
  This tag can be used to invalidate the cache entry by sending a `PURGE` request with the `xkey` header set to the same value like this:

  ```sh
  curl -sL -X PURGE -H 'xkey: TAG_VALUE' http://varnish-endpoint/
  ```

  Doing this will remove all cache entries that have the same tag value.

## 2.2.0

### Minor Changes

- d247546: It is now possible to enable logs, by setting `ENABLE_LOGS` to `true`, which is now the default value.
  To disable them, just put any other value, like `false` for example.

## 2.1.0

### Minor Changes

- 0a37f35: Support `PURGE` method to purge the cache

## 2.0.0

### Major Changes

- 6f6ea26: Changed base from Alpine to Ubuntu.

---

*Last updated: 2025-12-15*
