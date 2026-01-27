# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.10] - 2024-01-27
### Fixed
- Fixed **503 Service Unavailable** error by refactoring web server to uses explicit routes for `index.html` instead of root static mapping. This improves compatibility with Home Assistant Ingress.

## [0.1.9] - 2024-01-27
### Fixed
- Fixed `AttributeError` by correctly importing `aiohttp.web`.

## [0.1.8] - 2024-01-27
### Added
- Web Chat Interface! Includes a "Moltbot" sidebar item and a web UI accessible via Ingress.
- Exposed internal web server on port 8099.

## [0.1.7] - 2024-01-27
### Fixed
- Reverted to official `ws://supervisor/core/websocket` endpoint, now that Authorization headers are correctly implemented.
- Fixed `EOFError` encountered with direct connection attempts.

## [0.1.6] - 2024-01-27
### Fixed
- Updated `websockets.connect` call to use `additional_headers` (compatible with `websockets` v16.0+).

## [0.1.5] - 2024-01-27
### Fixed
- Changed authentication strategy to use direct internal `ws://homeassistant:8123/api/websocket` connection.
- Added `Authorization: Bearer <TOKEN>` header to WebSocket handshake for improved compatibility.

## [0.1.4] - 2024-01-27
### Fixed
- Forced `ws://supervisor/core/websocket` URL when using automatic authentication to prevent misconfiguration.
- Updated default `ha_url` in configuration options.

## [0.1.3] - 2024-01-27
### Fixed
- Corrected internal WebSocket URL logic to `ws://supervisor/core/websocket`.

## [0.1.2] - 2024-01-27
### Fixed
- Authentication "Invalid access" error by enabling `homeassistant_api` permission.
- Automated Home Assistant connection (no token required by default).

## [0.1.1] - 2024-01-27
### Added
- Dedicated Documentation tab (`DOCS.md`) with setup guides for tokens and integrations.
- Exponential backoff retry logic for HA connections.
- Visual assets (Icon/Logo).

### Fixed
- Add-on visibility issue caused by invalid schema syntax.
- Installation failure by switching to local builds.

## [0.1.0] - 2024-01-27
### Added
- Initial release of Moltbot-HA Bridge Add-on.
