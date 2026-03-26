#!/usr/bin/env python3

import ipaddress
import yaml

start_team = int(input("Starting team (int): "))
end_team = int(input("Ending team (int): "))


inventory = {
    "falco": {
        "hosts": {
            f"10.0.{team}.100": {
                "team": team,
                "ipv4": f"10.0.{team}.100",
                "ipv6": f"2600:1f26:001d:8b{team:02x}::fa1c:0",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "falco"
        }
    },
    "firewall": {
        "hosts": {
            f"10.0.{team}.254": {
                "team": team,
                "ipv4": f"10.0.{team}.254",
                "ipv6": f"2600:1f26:001d:8c{team:02x}:ffff:ffff:ffff:fffe",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "firewall"
        }
    },
    "grafana": {
        "hosts": {
            f"10.0.{team}.32": {
                "team": team,
                "ipv4": f"10.0.{team}.32",
                "ipv6": f"2600:1f26:001d:8b{team:02x}::beef:0",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "grafana"
        }
    },
    "kiosk": {
        "hosts": {
            f"2600:1f26:001d:8a{team:02x}::100:{server}": {
                "team": team,
                "ipv4": "",
                "ipv6": f"2600:1f26:001d:8a{team:02x}::100:{server}",
            }
            for team in range(start_team, end_team + 1)
            for server in range(1, 3)
        },
        "vars": {
            "hostname": "kiosk"
        }
    },
    "semaphore": {
        "hosts": {
            f"10.0.{team}.48": {
                "team": team,
                "ipv4": f"10.0.{team}.48",
                "ipv6": f"2600:1f26:001d:8b{team:02x}::dead:0",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "semaphore"
        }
    },
    "teleport": {
        "hosts": {
            f"10.0.{team}.148": {
                "team": team,
                "ipv4": f"10.0.{team}.148",
                "ipv6": "",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "teleport"
        }
    },
    "windows_ad": {
        "hosts": {
            f"10.0.{team}.120": {
                "team": team,
                "ipv4": f"10.0.{team}.120",
                "ipv6": f"2600:1f26:001d:8b{team:02x}:ab57:8ef2:ce6:42c1",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-ad"
        }
    },
    "windows_adfs": {
        "hosts": {
            f"10.0.{team}.110": {
                "team": team,
                "ipv4": f"10.0.{team}.110",
                "ipv6": f"2600:1f26:001d:8b{team:02x}::adf5:0",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-adfs"
        }
    },
    "windows_pos": {
        "hosts": {
            f"2600:1f26:001d:8a{team:02x}::cafe:0": {
                "team": team,
                "ipv4": "",
                "ipv6": f"2600:1f26:001d:8a{team:02x}::cafe:0",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-pos"
        }
    },
    "wordpress": {
        "hosts": {
            f"10.0.{team}.188": {
                "team": team,
                "ipv4": f"10.0.{team}.188",
                "ipv6": "",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "wordpress"
        }
    }
}

with open("0-inventory.yaml", "w") as file:
    yaml.dump(inventory, file, default_flow_style=False)

print("Updated hosts file")
