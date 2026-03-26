# Keycloak Configuration Files

Pre-built configuration and database for the Keycloak 26.5.4 instance in the `chefops` corp environment. Ansible copies this entire directory onto the target Windows server during deployment.

## Contents

```
files/keycloak/
├── generate.tf          # Terraform config that produces the H2 database
├── conf/
│   └── keycloak.conf    # Keycloak runtime configuration
└── data/
    └── h2/
        ├── keycloakdb.mv.db      # Pre-generated H2 database (committed artifact)
        └── keycloakdb.trace.db   # H2 diagnostic trace log
```

## Workflow: Generating the Database

The `data/h2/keycloakdb.mv.db` file is a pre-generated H2 embedded database. When the realm, clients, or LDAP configuration needs to change, regenerate it using the following process.

### 1. Spin up a local Keycloak instance

Run Keycloak locally in dev mode so Terraform can connect to it. The `generate.tf` provider is hardcoded to connect to `https://[::1]:8443` (or the IPv6 address in the file) with admin credentials `admin` / `changeme`.

Using Docker:

```bash
docker run --rm -p 8080:8080 -p 8443:8443 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=changeme \
  quay.io/keycloak/keycloak:26.5.4 start-dev
```

Or using the Windows binary directly on the target (or a local Windows machine):

```powershell
$env:KC_BOOTSTRAP_ADMIN_USERNAME = "admin"
$env:KC_BOOTSTRAP_ADMIN_PASSWORD = "changeme"
& "C:\Program Files\keycloak-26.5.4\bin\kc.bat" start-dev
```

Wait until the log shows `Keycloak 26.5.4 on JVM ... started`.

### 2. Apply the Terraform configuration

```bash
cd files/keycloak/
terraform init
terraform apply
```

This creates the following in the running Keycloak instance:

| Resource | Details |
|----------|---------|
| Realm | `chefops` — registration and password reset enabled |
| OIDC client | `grafana` — secret `fDkjsTd9ltjfqVlKOhdrunsT2I6kqNf2` |
| OIDC client | `semaphore` — secret `M8Dgy4Z5I7s80TLiMp4rd7NNcH8c4DDC` |
| OIDC client | `gitea` — secret `ggzIyvE7nsWDUA30BxPCeVyTsmsvns55` |
| Groups scope | OpenID `groups` mapper for group membership claims |
| LDAP federation | `chefops-ldap` → `ldaps://windows-dc01.ad.chefops.local:636` |
| LDAP user mapper | AD `department` → `Department`, `title` → `Position` |
| LDAP group mapper | Syncs groups from `OU=chefops,DC=ad,DC=chefops,DC=local` |
| Master realm user | `black-team` — Domain Admin service account (DO NOT TOUCH) |
| Master realm user | `keycloak_admin` — blue team admin account |

### 3. Copy the database back

Once `terraform apply` completes, stop Keycloak and copy the H2 database files back into this directory:

**Docker:**

```bash
# Find the container ID
docker ps

# Copy from the container's data directory
docker cp <container_id>:/opt/keycloak/data/h2/keycloakdb.mv.db data/h2/keycloakdb.mv.db
docker cp <container_id>:/opt/keycloak/data/h2/keycloakdb.trace.db data/h2/keycloakdb.trace.db
```

**Local Windows binary:**

```powershell
# Default data path when running start-dev from the install directory
Copy-Item "C:\Program Files\keycloak-26.5.4\data\h2\keycloakdb.mv.db" data\h2\keycloakdb.mv.db
Copy-Item "C:\Program Files\keycloak-26.5.4\data\h2\keycloakdb.trace.db" data\h2\keycloakdb.trace.db
```

Commit the updated `data/h2/keycloakdb.mv.db` — Ansible deploys this file directly to the target server.

---

## Runtime Configuration (`conf/keycloak.conf`)

| Setting | Value |
|---------|-------|
| Database | `dev-file` (embedded H2 at `data/h2/keycloakdb`) |
| HTTP | `0.0.0.0:80` |
| HTTPS | port `443`, certs from `conf/server.crt.pem` + `conf/server.key.pem` |
| Proxy headers | `xforwarded` |
| Health / Metrics | Enabled on port 80 (`/metrics`, `/health`) |
| Logging | JSON to `log/keycloak.log` + console (for Loki) |
| MDC keys | `realmName`, `clientId`, `userId`, `ipAddress`, `sessionId` |

TLS certificates (`server.crt.pem` / `server.key.pem`) are **not** stored here — they are injected by the Ansible `keycloak` role at deploy time from the team certificate path.

## Ansible Deployment

The Ansible `keycloak` role copies this entire directory to the Keycloak install path on the target server, then starts the Windows service. No manual steps are needed on the server — the pre-generated database contains all realm and client configuration.

See the `keycloak` role in `shared/roles/keycloak/` for deployment details.
