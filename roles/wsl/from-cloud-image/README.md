# Create WSL Instance from Ubuntu Cloud Image

This role creates a brand new WSL instance by downloading the specified version of the ubuntu cloud image [published by the Canonical team here](https://cloud-images.ubuntu.com/). it provisions the instance by using this cloud image as the disk.

You can use this role to create a brand new WSL instance from the daily build.

You can create a play that runs this role and force re-creates/re-downloads the template from the public image, delete the old one and re-deploys the new one. Useful for rebuilding your WSL instance every now and then.
