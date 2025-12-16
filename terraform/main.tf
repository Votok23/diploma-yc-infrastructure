# Локальные переменные
locals {
  vm_names = {
    web1     = "web1"
    web2     = "web2"
    zabbix   = "zabbix"
    elk      = "elasticsearch"
    kibana   = "kibana"
    bastion  = "bastion"
  }
  
  zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content  = local.ansible_inventory
  filename = "${path.module}/../ansible/inventory/hosts.ini"
}
