# A sample Proxmox Terraform Flatcar provisioning script

This repository has a script to provision Flatcar VM images using
Butane and Ignition from a preconfigured template VM.

A helper script is provided to manually provision a Proxmox VM template for
Flatcar. This is a versioned resource so that new versions of Flatcar can be
used for new VM's.

## Usage

To use the sample, set a `credentials.auto.tfvars` with the root username/password:

```terraform
pm_user         = "root@pam"
pm_password     = "password"
```

## Template creation

The `make_template.sh` script is provided to create a Proxmox template VM using the
Flatcar linux production qemu image.

Download the images (assuming a stable release is used):

```shell
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_uefi_efi_code.fd 
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_uefi_efi_vars.fd 
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_uefi_image.img.bz2 
bunzip2 flatcar_production_qemu_uefi_image.img.bz2
```
Create the template VM using the images.
```shell
./make_template.sh -n flatcar-production-qemu-3510.2.6 900
```
The *vars* image is used as the UEFI read-write variables device and the *code* image is a
read-only UEFI code device. 

# Links

- https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/

### Flatcar

- https://www.flatcar.org/
- Flatcar releases (https://www.flatcar.org/releases)
- https://www.flatcar.org/docs/latest/installing/vms/libvirt/
- https://github.com/flatcar/Flatcar/issues/430
- https://github.com/flatcar/ignition

### Ignition
- https://coreos.github.io/ignition
- https://github.com/flatcar/ignition
- https://www.iana.org/assignments/media-types/application/vnd.coreos.ignition+json

### Terraform

- https://registry.terraform.io/providers/Telmate/proxmox/latest
- https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
- https://github.com/poseidon/terraform-provider-ct
- https://registry.terraform.io/providers/poseidon/ct/latest/docs
- https://www.flatcar.org/docs/latest/provisioning/config-transpiler/


### Proxmox
- https://pve.proxmox.com/wiki/Manual:_qm.conf

### Qemu
- https://github.com/qemu/qemu/blob/master/docs/specs/fw_cfg.rst
- https://www.qemu.org/docs/master/specs/fw_cfg.html

### UEFI
- https://joonas.fi/2021/02/uefi-pc-boot-process-and-uefi-with-qemu/#uefi-is-not-bios

## Known Limitations

As of August 2023, the following limitation and residuals have been observed:

1. The Proxmox API requires the 'root@pam' user to provision 'args'. Using 
an API key doesn't work, and using an API key for root also doesn't work, 
as the username 'root@pam!terraform' doesn't match the required identity of 'root@pam'.

2. The terraform script doesn't perform a full destroy/create cycle on the VM when the butane 
configuration changes. Given the Flatcar VM will only apply the configuration on first 
boot, the updated configuration will not be applied.

3. The Qemu command line parsing requires to the Ignition configuration to have all 
comma's escaped with another comma (i.e. a double comma)

4. Ignition support in Flatcar linux is limited to version 1.1.0

5. When creating a Proxmox UEFI VM with a pre-made image, the special `file=<storage>:0`
syntax must be used. e.g. if the node local disk is called 'local' then the syntax would be:
```
   --efidisk0 "file=local:0,import-from=flatcar_production_qemu_image.img,efitype=4m,format=raw,pre-enrolled-keys=1"
```

6. Although the flatcar linux qemu image has a `.img` extension, it is 
a [qcow2](https://en.wikipedia.org/wiki/Qcow) formatted file. The image
has multiple partitions.

7. The documentation isn't clear as to the correct way to mount UEFI code partitions as
a read-only volume. It is unclear how to specify a pflash drive for the UEFI code. To see
the Qemu configuration run `qm showcmd <vm id> --pretty`, which shows the two EFI
pflash drives.

8. Terraform Telmate/Proxmox provider doesn't support setting the hookscript upon , thus
the hookscript must be set in the template and inherited to child VM's.

9. The proxmox hook script locks the vm configuration - thus stopping the hook script
from modifying/mutating the configuration. Even if the configuration is changed the
Proxmox *start* code will not reload the changes after the hookscript runs.

10. It appears that Butane produces ignition v3.x.x configurations, whereas Flatcar 'stable'
will only consume ignition v2.x.x configurations (test after the first boot by injecting a
`fw_cfg` with versions and run `ignition --log-to-stdout --platform qemu -stage fetch`). Flatcar
v3510.2.6 uses Ignition v2.14.0