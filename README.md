Debian Image for Networking Labs
================================

Debian QEMU image for networking labs.

Requirements
------------

System requirements:

- Bourne shell (`sh`)
- Git
- Python 3
- [Packer][Packer]
- [QEMU][QEMU]

[Packer]: https://developer.hashicorp.com/packer/docs
[QEMU]: https://www.qemu.org/download/

Install project requirements:

```sh
./install-requirements.sh
```

Configuration
-------------

Specify password of the `root` user, name and password of the initial user in
the `build.local.auto.pkrvars.hcl` file. Example:

```
root_password = "RootP@ssw0rD"
user_name     = "alice"
user_password = "AliceP@ssw0rD"
```

If you are running Packer on a macOS host, add the following configuration
to the `build.local.auto.pkrvars.hcl` file:

```
qemu_accelerator         = "hvf"
qemu_use_default_display = true
```

TFTP data provisioning example:

```sh
mkdir data/tftp
echo '*' > `data/tftp/.gitignore
cp ${boot_image_source} data/tftp/boot.img
cat << __EOF__ > inventory/host_vars/default/tftp.yml
tftp_data:
  - data/tftp/boot.img
__EOF__
```

Build
-----

Activate Python virtual environment:

```sh
. .venv/bin/activate
```

Build:

```sh
packer build .
```

The build result is saved to `output/debian.qcow2` file.
