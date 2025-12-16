# Создание VPC
resource "yandex_vpc_network" "diploma_vpc" {
  name        = var.vpc_name
  description = "VPC for diploma project"
}

# Создание подсетей
resource "yandex_vpc_subnet" "diploma_subnets" {
  count          = length(var.vpc_subnet_cidrs)
  name           = "${var.vpc_name}-subnet-${count.index}"
  zone           = local.zones[count.index % length(local.zones)]
  network_id     = yandex_vpc_network.diploma_vpc.id
  v4_cidr_blocks = [var.vpc_subnet_cidrs[count.index]]
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

# Security Group для bastion
resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Security group for bastion host"
  network_id  = yandex_vpc_network.diploma_vpc.id

  ingress {
    description    = "SSH from anywhere"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для web серверов
resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web servers"
  network_id  = yandex_vpc_network.diploma_vpc.id

  ingress {
    description       = "HTTP from load balancer"
    protocol          = "TCP"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "HTTP from internal network"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.internal_sg.id
  }

  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  ingress {
    description       = "Zabbix agent"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.zabbix_sg.id
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Zabbix
resource "yandex_vpc_security_group" "zabbix_sg" {
  name        = "zabbix-security-group"
  description = "Security group for Zabbix server"
  network_id  = yandex_vpc_network.diploma_vpc.id

  ingress {
    description    = "HTTP from anywhere"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS from anywhere"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Zabbix agent from internal"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.internal_sg.id
  }

  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для ELK
resource "yandex_vpc_security_group" "elk_sg" {
  name        = "elk-security-group"
  description = "Security group for ELK stack"
  network_id  = yandex_vpc_network.diploma_vpc.id

  ingress {
    description    = "Kibana HTTP from anywhere"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Elasticsearch from internal"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.internal_sg.id
  }

  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для внутреннего трафика
resource "yandex_vpc_security_group" "internal_sg" {
  name        = "internal-security-group"
  description = "Security group for internal traffic"
  network_id  = yandex_vpc_network.diploma_vpc.id

  ingress {
    description    = "Allow all internal traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# NAT gateway для исходящего интернета
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.diploma_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
