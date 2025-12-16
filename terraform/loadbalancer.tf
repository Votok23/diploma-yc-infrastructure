# Target Group для web серверов
resource "yandex_alb_target_group" "web_target_group" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.diploma_subnets[0].id
    ip_address = yandex_compute_instance.web[0].network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.diploma_subnets[1 % length(yandex_vpc_subnet.diploma_subnets)].id
    ip_address = yandex_compute_instance.web[1].network_interface[0].ip_address
  }
}

# Backend Group
resource "yandex_alb_backend_group" "web_backend_group" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_target_group.id]

    healthcheck {
      timeout   = "10s"
      interval  = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15

      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP Router
resource "yandex_alb_http_router" "web_router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web_virtual_host" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend_group.id
        timeout          = "60s"
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "diploma_balancer" {
  name        = "diploma-balancer"
  network_id  = yandex_vpc_network.diploma_vpc.id

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.diploma_subnets[0].id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}
