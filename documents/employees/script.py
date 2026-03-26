#!/usr/bin/env python3
"""
Generate test user information for NECCDC 2026

Dependencies: pip install pyotp pyyaml requests
Usage: python3 /workspaces/neccdc-2026/documents/employees/script.py
"""

import pyotp
import yaml
import requests
import unicodedata
from typing import Dict, List, Optional


def fetch_random_user() -> Optional[Dict]:
    """
    Fetch a random user from randomuser.me API.

    Returns:
        Dictionary containing user data from the API or None if failed
    """
    try:
        response = requests.get(
            url = "https://randomuser.me/api/",
            params = {
              "nat": "us,dk,fr,gb",
              "noinfo": True
            }
        )
        response.raise_for_status()
        data = response.json()
        return data['results'][0]
    except Exception as e:
        print(f"Error fetching random user: {e}")
        return None

def to_ascii(text: str) -> str:
    """
    Convert a string to ASCII-safe format by removing accents and non-ASCII characters.

    Args:
        text: Input string that may contain non-ASCII characters

    Returns:
        ASCII-safe string
    """
    # Normalize to NFD (decompose characters with accents)
    normalized = unicodedata.normalize('NFD', text)
    # Filter out combining characters (accents) and keep only ASCII
    ascii_text = ''.join(char for char in normalized if unicodedata.category(char) != 'Mn' and ord(char) < 128)
    return ascii_text

def generate_user_from_api(domain: str = "example.com") -> Optional[Dict[str, str]]:
    """
    Generate complete user information using randomuser.me API.

    Args:
        domain: Email domain (default: example.com)

    Returns:
        Dictionary containing user information or None if API call fails
    """
    api_user = fetch_random_user()
    if not api_user:
        return None

    first_name = api_user['name']['first']
    last_name = api_user['name']['last']

    # Convert to ASCII-safe format for username and email
    first_name_ascii = to_ascii(first_name)
    last_name_ascii = to_ascii(last_name)

    username = (first_name_ascii[0] + last_name_ascii).lower()
    password = api_user['login']['password']
    email = f"{username}@{domain}"
    totp_secret = pyotp.random_base32()

    return {
        "first_name": first_name,
        "last_name": last_name,
        "username": username,
        "email": email,
        "password": password,
        "totp_secret": totp_secret,
        "department": "MISSING_DEPARTMENT",
        "position": "MISSING_POSITION",
        "employee_id": "0",
        "manager_id": "0"
    }

def generate_multiple_users_from_api(count: int, domain: str = "example.com") -> List[Dict[str, str]]:
    """
    Generate information for multiple users using randomuser.me API.

    Args:
        count: Number of users to generate
        domain: Email domain

    Returns:
        List of user information dictionaries
    """
    users = []
    for i in range(count):
        user = generate_user_from_api(domain)
        if user:
            users.append(user)
        else:
            print(f"Failed to generate user {i+1}/{count}")
    return users


def write_users_to_yaml(users: List[Dict[str, str]], filename: str = "users.yaml") -> None:
    """
    Write user information to a YAML file.

    Args:
        users: List of user information dictionaries
        filename: Output filename (default: users.yaml)
    """
    output_data = {
        "users": users
    }

    with open(filename, 'w') as f:
        yaml.dump(output_data, f, default_flow_style=False, sort_keys=False)

    print(f"User information written to {filename}")
    print(f"Total users generated: {len(users)}")


def main():
    """Main function demonstrating usage."""
    domain = "chefops.tech"
    user_count = 17

    print("Generating test users from randomuser.me API...\n")

    # Generate users from API
    all_users = generate_multiple_users_from_api(user_count, domain)

    # Write all users to YAML file
    write_users_to_yaml(all_users, "users.yaml")


if __name__ == "__main__":
    main()
