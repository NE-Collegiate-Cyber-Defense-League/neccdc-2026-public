# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-11-03

### Added
- Initial release
- WSUS installation and configuration for Windows Server 2016/2019/2022/2025
- Automatic product and classification configuration
- Computer target group creation (Domain Controllers, Servers, Workstations)
- Automatic synchronization scheduling with local-to-UTC timezone conversion
- Optional initial synchronization
- Comprehensive configuration summary output
- Support for upstream WSUS servers
- Proxy configuration support (with and without authentication)
- Custom content and log folder paths
- OOBE wizard auto-completion (suppresses first-run wizard)
- Microsoft Update Improvement Program (telemetry) disabled by default
- Server-side and client-side targeting mode support
- Configurable sync frequency (1-24 times per day)
- Multi-language update support
- Default approval rule configuration
- Windows Firewall rules for HTTP (8530) and HTTPS (8531)

### Features
- Empty product/classification lists by default (intentional for labs - allows manual GUI configuration)
- Fast deployment without initial sync (~5 minutes)
- Proper DST/timezone handling for sync schedules
- Idempotent - safe to re-run
- Comprehensive validation of configuration parameters

### Tested
- Windows Server 2022 (primary testing platform)
- Product and classification selection
- Timezone conversion including DST transitions
- Auto-sync scheduling
- Target group creation
- Empty product/classification lists (manual GUI configuration)
- Initial synchronization

### Known Limitations
- Fixed ports 8530 (HTTP) and 8531 (HTTPS) only - custom ports not supported
- Upstream WSUS, proxy authentication, client-side targeting, and multi-language configurations not extensively tested but should work

### Notes
- Role designed for Ludus ephemeral lab environments
- Emphasizes fast deployment and user control over automatic configuration