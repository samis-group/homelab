terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
    ansiblevault = {
      source = "MeilleursAgents/ansiblevault"
      version = "2.2.0"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://${data.ansiblevault_path.proxmox_host}:${data.ansiblevault_path.proxmox_port}/api2/json"
  pm_password = data.ansiblevault_path.proxmox_api_pass
  pm_user = data.ansiblevault_path.proxmox_api_user
}

# provider "ansiblevault" {
#   # Configuration options
# }

/* Uses Cloud-Init options from Proxmox 5.2 */
resource "proxmox_vm_qemu" "cloudinit-test" {
  name        = "tftest1.${data.ansiblevault_path.domain_name}"
  desc        = "tf description"
  target_node = data.ansiblevault_path.proxmox_node

  clone = "UbuntuCloud-22.04"

  # Activate QEMU agent for this VM
  agent = 1

  os_type   = "cloud-init"
  cores   = 2
  sockets = 2
  memory  = 2048
  scsihw = "lsi"

  # Setup the disk
  disk {
    size = 10
    type = "virtio"
    storage = "local-lvm"
    storage_type = "rbd"
    iothread = 1
    ssd = 1
    discard = "on"
  }

  # Setup the network interface and assign a vlan tag: 256
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=${data.ansiblevault_path.vault_vm_network}76/24,gw=${data.ansiblevault_path.vault_vm_gateway}"

  sshkeys = local.ssh_key_pub

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]
  }
}

# /* Null resource that generates a cloud-config file per vm */
# data "template_file" "user_data" {
#   count    = data.ansiblevault_path.vm_count
#   template = file("${path.module}/files/user_data.cfg")
#   vars     = {
#     pubkey   = file(pathexpand("~/.ssh/id_rsa.pub"))
#     hostname = "vm-${count.index}"
#     fqdn     = "vm-${count.index}.${data.ansiblevault_path.domain_name}"
#   }
# }
# resource "local_file" "cloud_init_user_data_file" {
#   count    = data.ansiblevault_path.vm_count
#   content  = data.template_file.user_data[count.index].rendered
#   filename = "${path.module}/files/user_data_${count.index}.cfg"
# }

# resource "null_resource" "cloud_init_config_files" {
#   count = data.ansiblevault_path.vm_count
#   connection {
#     type     = "ssh"
#     user     = "${data.ansiblevault_path.pve_user}"
#     password = "${data.ansiblevault_path.pve_password}"
#     host     = "${data.ansiblevault_path.pve_host}"
#   }

#   provisioner "file" {
#     source      = local_file.cloud_init_user_data_file[count.index].filename
#     destination = "/var/lib/vz/snippets/user_data_vm-${count.index}.yml"
#   }
# }

# /* Configure Cloud-Init User-Data with custom config file */
# resource "proxmox_vm_qemu" "cloudinit-test" {
#   depends_on = [
#     null_resource.cloud_init_config_files,
#   ]

#   name        = "tftest1.xyz.com"
#   desc        = "tf description"
#   target_node = "proxmox1-xx"

#   clone = "ci-ubuntu-template"

#   # The destination resource pool for the new VM
#   pool = "pool0"

#   storage = "local"
#   cores   = 3
#   sockets = 1
#   memory  = 2560
#   disk_gb = 4
#   nic     = "virtio"
#   bridge  = "vmbr0"

#   ssh_user        = "root"
#   ssh_private_key = <<EOF
# private ssh key root
# EOF

#   os_type   = "cloud-init"
#   ipconfig0 = "ip=10.0.2.99/16,gw=10.0.2.2"

#   /*
#     sshkeys and other User-Data parameters are specified with a custom config file.
#     In this example each VM has its own config file, previously generated and uploaded to
#     the snippets folder in the local storage in the Proxmox VE server.
#   */
#   cicustom                = "user=local:snippets/user_data_vm-${count.index}.yml"
#   /* Create the Cloud-Init drive on the "local-lvm" storage */
#   cloudinit_cdrom_storage = "local-lvm"

#   provisioner "remote-exec" {
#     inline = [
#       "ip a"
#     ]
#   }
# }

# /* Uses custom eth1 user-net SSH portforward */
# resource "proxmox_vm_qemu" "preprovision-test" {
#   name        = "tftest1.xyz.com"
#   desc        = "tf description"
#   target_node = "proxmox1-xx"

#   clone = "terraform-ubuntu1404-template"

#   # The destination resource pool for the new VM
#   pool = "pool0"

#   cores    = 3
#   sockets  = 1
#   # Same CPU as the Physical host, possible to add cpu flags
#   # Ex: "host,flags=+md-clear;+pcid;+spec-ctrl;+ssbd;+pdpe1gb"
#   cpu      = "host"
#   numa     = false
#   memory   = 2560
#   scsihw   = "lsi"
#   # Boot from hard disk (c), CD-ROM (d), network (n)
#   boot     = "cdn"
#   # It's possible to add this type of material and use it directly
#   # Possible values are: network,disk,cpu,memory,usb
#   hotplug  = "network,disk,usb"
#   # Default boot disk
#   bootdisk = "virtio0"
#   # HA, you need to use a shared disk for this feature (ex: rbd)
#   hastate  = ""

#   #Display
#   vga {
#     type   = "std"
#     #Between 4 and 512, ignored if type is defined to serial
#     memory = 4
#   }

#   network {
#     id    = 0
#     model = "virtio"
#   }
#   network {
#     id     = 1
#     model  = "virtio"
#     bridge = "vmbr1"
#   }
#   disk {
#     id           = 0
#     type         = "virtio"
#     storage      = "local-lvm"
#     storage_type = "lvm"
#     size         = "4G"
#     backup       = true
#   }
#   # Serial interface of type socket is used by xterm.js
#   # You will need to configure your guest system before being able to use it
#   serial {
#     id   = 0
#     type = "socket"
#   }
#   preprovision    = true
#   ssh_forward_ip  = "10.0.0.1"
#   ssh_user        = "terraform"
#   ssh_private_key = <<EOF
# private ssh key terraform
# EOF

#   os_type           = "ubuntu"
#   os_network_config = <<EOF
# auto eth0
# iface eth0 inet dhcp
# EOF

#   connection {
#     type        = "ssh"
#     user        = self.ssh_user
#     private_key = self.ssh_private_key
#     host        = self.ssh_host
#     port        = self.ssh_port
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "ip a"
#     ]
#   }
# }
