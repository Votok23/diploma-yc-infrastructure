# Получение образа Ubuntu 22.04
data "yandex_compute_image" "ubuntu_2204" {
  family = "ubuntu-2204-lts"
}

# Создание SSH ключа
resource "yandex_compute_instance" "bastion" {
  name        = local.vm_names.bastion
  hostname    = local.vm_names.bastion
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.vm_bastion_cores
    memory = var.vm_bastion_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.vm_bastion_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.diploma_subnets[0].id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.bastion_sg.id,
      yandex_vpc_security_group.internal_sg.id
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = false
  }

  allow_stopping_for_update = true
}

# Создание web серверов
resource "yandex_compute_instance" "web" {
  count       = var.vm_web_count
  name        = "web${count.index + 1}"
  hostname    = "web${count.index + 1}"
  platform_id = "standard-v3"
  zone        = local.zones[count.index % length(local.zones)]

  resources {
    cores  = var.vm_web_cores
    memory = var.vm_web_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.vm_web_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.diploma_subnets[count.index].id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.web_sg.id,
      yandex_vpc_security_group.internal_sg.id
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = false
  }

  allow_stopping_for_update = true
}

# Создание Zabbix сервера
resource "yandex_compute_instance" "zabbix" {
  name        = local.vm_names.zabbix
  hostname    = local.vm_names.zabbix
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.vm_zabbix_cores
    memory = var.vm_zabbix_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.vm_zabbix_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.diploma_subnets[0].id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.zabbix_sg.id,
      yandex_vpc_security_group.internal_sg.id
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = false
  }

  allow_stopping_for_update = true
}

# Создание Elasticsearch сервера
resource "yandex_compute_instance" "elasticsearch" {
  name        = local.vm_names.elk
  hostname    = local.vm_names.elk
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = var.vm_elk_cores
    memory = var.vm_elk_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.vm_elk_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.diploma_subnets[1].id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.elk_sg.id,
      yandex_vpc_security_group.internal_sg.id
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = false
  }

  allow_stopping_for_update = true
}

# Создание Kibana сервера
resource "yandex_compute_instance" "kibana" {
  name        = local.vm_names.kibana
  hostname    = local.vm_names.kibana
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.vm_elk_cores
    memory = var.vm_elk_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.vm_elk_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.diploma_subnets[0].id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.elk_sg.id,
      yandex_vpc_security_group.internal_sg.id
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = false
  }

  allow_stopping_for_update = true
}
