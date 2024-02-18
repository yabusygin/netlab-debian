build {
  source "qemu.debian" {
    vm_name          = "debian"
    output_directory = "output"
  }

  provisioner "ansible" {
    playbook_file       = "${path.root}/provision.yml"
    inventory_directory = "${path.root}/inventory"
  }

  post-processor "shell-local" {
    inline = [
      "mv output/debian output/debian.qcow2"
    ]
  }
}
