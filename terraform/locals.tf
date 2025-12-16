locals {
  # Generate Ansible inventory
  ansible_inventory = templatefile("${path.module}/templates/inventory.tpl", {
    bastion_public_ip   = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
    bastion_private_ip  = yandex_compute_instance.bastion.network_interface[0].ip_address
    web_servers         = yandex_compute_instance.web
    zabbix_private_ip   = yandex_compute_instance.zabbix.network_interface[0].ip_address
    elasticsearch_private_ip = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
    kibana_private_ip   = yandex_compute_instance.kibana.network_interface[0].ip_address
    ssh_username        = var.ssh_username
  })
  
  # Security group IDs for output if needed
  sg_ids = {
    bastion      = yandex_vpc_security_group.bastion_sg.id
    web          = yandex_vpc_security_group.web_sg.id
    zabbix       = yandex_vpc_security_group.zabbix_sg.id
    elk          = yandex_vpc_security_group.elk_sg.id
    internal     = yandex_vpc_security_group.internal_sg.id
  }
}
