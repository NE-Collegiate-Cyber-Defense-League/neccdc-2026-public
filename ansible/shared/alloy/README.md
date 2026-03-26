# Alloy Setup

Sets up [Alloy monitoring agent](https://grafana.com/docs/alloy/latest/) on target hosts. This has basic configuration for sending metrics to Grafana Mimir and logs to Grafana Loki instances hosted by ChefOps Tech.

## Variables

### Required Variables

- `mode` (string)
  - Mode in which to run the Alloy setup tasks. Must be either `"pre"` or `"post"`. PRE tasks install and apply initial configuration for Alloy, while POST tasks finalize configuration (pointing to each teams instance) and start the Alloy service.


### Optional Variables

#### Variables for PRE Mode
- `include_docker` (boolean, default: `false`)
  - Whether to include Docker monitoring configuration in Alloy setup. Set to `true` to enable Docker metrics and logs collection if Docker is installed on the target host.
- `extra_config` (string, default: `""`)
  - Additional Alloy configuration snippets to append to the Alloy config file. This allows for custom configuration beyond the defaults provided by this role. The format is the raw Alloy configuration syntax called river.

#### Variables for POST Mode
- `mimir_server_name` (string, default: `"https://mimir.<team_number>.chefops.tech"`)
  - Hostname or IP address of the Grafana Mimir instance to which Alloy should send metrics.
- `loki_server_name` (string, default: `"https://loki.<team_number>.chefops.tech"`)
  - Hostname or IP address of the Grafana Loki instance to which Alloy should send logs