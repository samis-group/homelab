#!/usr/bin/env python
import subprocess
import sys
import os

def get_doppler_secret(secret_name):
    cmd = ["doppler", "secrets", "get", secret_name, "--plain"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        print(result.stdout.strip())
        # return result.stdout.strip()
    else:
        raise Exception(f"Failed to fetch Doppler secrets for {secret_name}")

if __name__ == "__main__":
    # Check if an argument is provided, otherwise check environment variable
    secret_name = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("DOPPLER_SECRET_INVENTORY")

    if not secret_name:
        print("Error: Provide Doppler secret name as an argument or set DOPPLER_SECRET_INVENTORY environment variable.")
        sys.exit(1)

    get_doppler_secret(secret_name)
