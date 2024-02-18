packer {
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
    sshkey = {
      version = "~> 1.0"
      source  = "github.com/ivoronin/sshkey"
    }
  }
}

variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "The accelerator type to use when running the VM."
}

variable "cpu_count" {
  type        = number
  default     = 1 # https://www.debian.org/releases/stable/amd64/ch03s04.en.html
  description = "Count of CPUs."
}

variable "memory_size" {
  type        = number
  default     = 512 # https://www.debian.org/releases/stable/amd64/ch03s04.en.html
  description = "Memory size in MiB."
}

variable "drive_size" {
  type        = number
  default     = 10
  description = "Drive size in GiB."
}

variable "qemu_use_default_display" {
  type        = bool
  default     = false
  description = "Do not pass a \"-display\" option to QEMU."
}

variable "headless" {
  type        = bool
  default     = false
  description = "Do not launch a GUI that shows the console of the VM."
}

variable "install_image" {
  type        = string
  default     = "https://cdimage.debian.org/cdimage/archive/11.8.0/amd64/iso-cd/debian-11.8.0-amd64-netinst.iso"
  description = "URL of the installation image."
}

variable "install_image_hash" {
  type        = string
  default     = "sha512:da7e7867ed043b784f5ae7e4adaaf4f023b5235f0fa2ead1279dc93f74bc17801ed906d330e3cd68ee8d3e96b697d21d23cfe2b755f5a9eb555bd5390a8c4dac"
  description = "Hash of the the installation image."
}

# d-i debian-installer/country
# d-i mirror/country
variable "country" {
  type        = string
  default     = "US"
  description = "ISO country code."
}

# d-i time/zone
variable "time_zone" {
  type        = string
  default     = "US/Eastern"
  description = "Time zone name."
}

# d-i netcfg/hostname
variable "hostname" {
  type        = string
  default     = "debian"
  description = "Name of the host system."
}

# d-i passwd/root-password
variable "root_password" {
  type        = string
  sensitive   = true
  description = "Password of the root user."
}

# d-i passwd/user-fullname
# d-i passwd/username
variable "user_name" {
  type        = string
  sensitive   = true
  description = "Name of the initial user."
}

# d-i passwd/user-password
variable "user_password" {
  type        = string
  sensitive   = true
  description = "Password of the initial user."
}

# d-i debian-installer/add-kernel-opts
variable "kernel_options" {
  type        = string
  default     = ""
  description = "Boot parameters for the installed system."
}

data "sshkey" "provision" {
  type = "ed25519"
}

source "qemu" "debian" {
  machine_type = "pc"
  accelerator  = var.qemu_accelerator

  cpus      = var.cpu_count
  memory    = var.memory_size
  disk_size = var.drive_size * 1024

  disk_interface = "virtio"
  format         = "qcow2"

  net_device = "virtio-net-pci"

  use_default_display = var.qemu_use_default_display
  headless            = var.headless

  iso_url      = var.install_image
  iso_checksum = var.install_image_hash

  http_content = {
    "/preseed.cfg" = templatefile(
      "${path.root}/autoinstall/preseed.cfg.pkrtpl.hcl",
      {
        country                      = var.country
        time_zone                    = var.time_zone
        hostname                     = var.hostname
        root_password                = var.root_password
        user_name                    = var.user_name
        user_password                = var.user_password
        kernel_options               = var.kernel_options
        provision_ssh_authorized_key = data.sshkey.provision.public_key
      }
    )
  }

  boot_wait = "5s"

  # https://www.debian.org/releases/stable/amd64/apb.en.html
  boot_command = [
    "<esc><wait>",
    "auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
  ]

  ssh_username         = "root"
  ssh_private_key_file = data.sshkey.provision.private_key_path
  ssh_timeout          = "20m"

  shutdown_command = "shutdown --poweroff now"
}
