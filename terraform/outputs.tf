output "vpc_id" {
  description = "ID of the created VPC"
  value       = yandex_vpc_network.diploma_vpc.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = [for subnet in yandex_vpc_subnet.diploma_subnets : subnet.id]
}

output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_servers_fqdn" {
  description = "FQDN of web servers"
  value       = [for vm in yandex_compute_instance.web : "${vm.name}.ru-central1.internal"]
}

output "zabbix_fqdn" {
  description = "FQDN of Zabbix server"
  value       = yandex_compute_instance.zabbix.name != "" ? "${yandex_compute_instance.zabbix.name}.ru-central1.internal" : ""
}

output "elasticsearch_fqdn" {
  description = "FQDN of Elasticsearch server"
  value       = yandex_compute_instance.elasticsearch.name != "" ? "${yandex_compute_instance.elasticsearch.name}.ru-central1.internal" : ""
}

output "kibana_fqdn" {
  description = "FQDN of Kibana server"
  value       = yandex_compute_instance.kibana.name != "" ? "${yandex_compute_instance.kibana.name}.ru-central1.internal" : ""
}

output "load_balancer_public_ip" {
  description = "Public IP address of load balancer"
  value       = yandex_alb_load_balancer.diploma_balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "ansible_inventory" {
  description = "Ansible inventory content"
  value       = local.ansible_inventory
  sensitive   = true
}
