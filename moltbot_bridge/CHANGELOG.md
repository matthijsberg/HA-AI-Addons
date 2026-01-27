# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
