#!/usr/bin/env python3

import ipaddress
import yaml

start_team = int(input("Starting team (int): "))
end_team = int(input("Ending team (int): "))


inventory = {
    "firewall_branch": {
        "hosts": {
            f"2600:1f26:001d:8b{team:01x}0:ffff:ffff:ffff:fffe": {
                "team": team,
                "ipv4": f"10.100.{team}.254",
                "ipv6": f"2600:1f26:001d:8b{team:01x}0:ffff:ffff:ffff:fffe",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "firewall"
        }
    },
    "firewall_corp": {
        "hosts": {
            f"10.7.{team}.254": {
                "team": team,
                "ipv4": f"10.7.{team}.254",
                "ipv6": f"2600:1f26:001d:8a{team:01x}0:ffff:ffff:ffff:fffe",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "firewall"
        }
    },
    "gitea": {
        "hosts": {
            f"2600:1f26:001d:8a{team:01x}2::feed": {
                "team": team,
                "ipv6": f"2600:1f26:001d:8a{team:01x}2::feed",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "gitea"
        }
    },
    "grafana": {
        "hosts": {
            f"2600:1f26:001d:8a{team:01x}2:0:ace::": {
                "team": team,
                "ipv6": f"2600:1f26:001d:8a{team:01x}2:0:ace::",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "grafana"
        }
    },
    "kiosks": {
        "hosts": {
            f"2600:1f26:001d:8b{team:01x}1:200::{server}": {
                "team": team,
                "ipv4": f"10.100.{team}.20{server}",
                "ipv6": f"2600:1f26:001d:8b{team:01x}1:200::{server}",
                "id": server,
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
            f"2600:1f26:001d:8a{team:01x}2:d09:ca7:b15d:f158": {
                "team": team,
                "ipv6": f"2600:1f26:001d:8a{team:01x}2:d09:ca7:b15d:f158",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "semaphore"
        }
    },
    "teleport_branch": {
        "hosts": {
            f"10.100.{team}.100": {
                "team": team,
                "ipv4": f"10.100.{team}.100",
                "ipv6": f"2600:1f26:001d:8b{team:01x}1::beef",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "teleport"
        }
    },
    "teleport_corp": {
        "hosts": {
            f"10.3.{team}.128": {
                "team": team,
                "ipv4": f"10.3.{team}.128",
                "ipv6": f"2600:1f26:001d:8a{team:01x}1::c0de",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "teleport"
        }
    },
    "corp_win_dc": {
        "hosts": {
            f"2600:1f26:001d:8a{team:01x}2::ad": {
                "team": team,
                "ipv6": f"2600:1f26:001d:8a{team:01x}2::ad",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-dc01"
        }
    },
    "corp_win_srv": {
        "hosts": {
            f"2600:1f26:001d:8a{team:01x}2::adf5": {
                "team": team,
                "ipv6": f"2600:1f26:001d:8a{team:01x}2::adf5",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-srv01"
        }
    },
    "branch_win_pos": {
        "hosts": {
            f"2600:1f26:001d:8b{team:01x}1::cafe": {
                "team": team,
                "ipv4": f"10.100.{team}.37",
                "ipv6": f"2600:1f26:001d:8b{team:01x}1::cafe",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-pos"
        }
    },
    "branch_win_dc": {
        "hosts": {
            f"2600:1f26:001d:8b{team:01x}1::f00d": {
                "team": team,
                "ipv4": f"10.100.{team}.64",
                "ipv6": f"2600:1f26:001d:8b{team:01x}1::f00d",
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "windows-dc02"
        }
    },
    "wordpress": {
        "hosts": {
            f"10.3.{team}.200": {
                "team": team,
                "ipv4": f"10.3.{team}.200",
                "ipv6": f"2600:1f26:001d:8a{team:01x}1::be57:bad0",
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
