# alloy

Grafana Alloy module for ingesting and parsing pfSense syslog (`filterlog`) into Loki.

## Files

- `module.alloy`: Declares `pfsense_logs`, a reusable logs pipeline.

## What the module does

- Listens for syslog on `0.0.0.0:55514/udp`.
- Sets `job="pfsense"` and relabels common syslog fields.
- Parses pfSense `filterlog` CSV payloads for IPv4 and IPv6.
- Extracts protocol and ports (TCP/UDP) when present.
- Forwards processed logs to a caller-provided `forward_to` receiver list.

## Usage

### 1) Import the module from Gitea

```alloy
import.git "alloy_repo" {
	repository = "http://gitea.X.chefops.tech:3000/chefops/alloy.git"
	path       = "module.alloy"
}
```

### 2) Instantiate the module and wire to Loki

```alloy
alloy_repo.pfsense_logs {
	forward_to = [loki.write.local.receiver]
}
```

## pfSense remote logging settings

Configure pfSense to send syslog to the Alloy host:

- **Target IP**: Alloy server IP
- **Port**: `55514`
- **Transport**: `UDP`
- **Format**: RFC 5424 syslog (default)
- **Categories**: include Firewall Events / `filterlog`
