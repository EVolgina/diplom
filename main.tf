# Использование существующего сервисного аккаунта
locals {
  service_account_id = "ajetnpf6s7pt87g5bdvt"
}
# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "ajetnpf6s7pt87g5bdvt"
  description        = "static access key for object storage"
}
# Создание бакета Object Storage
#resource "yandex_storage_bucket" "paint" {
#  bucket = "paint"  # имя для бакета
#}
# Выходные данные для ключей
output "bucket_access_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive = true
}
# Создание сети
resource "yandex_vpc_network" "netology-net" {
  name = "netology-net"
}

# Создание подсети
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology-net.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology-net.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}
#resource "yandex_vpc_subnet" "subnet-c" {
#  name           = "subnet-c"
#  zone           = "ru-central1-c"
#  network_id     = yandex_vpc_network.netology-net.id
#  v4_cidr_blocks = ["10.0.2.0/24"]
#}
# Конфигурация Terraform
terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket     = "paint"
    region = "ru-central1"
    key        = "terraform/state"
    access_key = "YCAJEycW1ufgWEU9TD-xTdzqp"
    secret_key = "YCPrR_XbGDC7JF5h2KY0TPM4-3P5YPKYz8PIfhqq"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
# Создание группы целей для балансировщика нагрузки
resource "yandex_lb_target_group" "target-group" {
  name = "target-group"
  target {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    address   = "10.0.0.10"
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    address   = "10.0.1.10"
  }
#  target {
#    subnet_id = yandex_vpc_subnet.subnet-c.id
#    address   = "10.0.2.10"
#  }
}
# Создание группы виртуальных машин
resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-group"
  folder_id          = "b1gpoeqn2q7if0pboa4u"
  service_account_id = local.service_account_id
  instance_template {
    platform_id = "standard-v1"
    resources {
      cores  = 2
      memory = 2
      core_fraction = 20
      }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    scheduling_policy {
         preemptible = true
      }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.subnet-a.id, yandex_vpc_subnet.subnet-b.id]
    }
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion = 2
  }
  health_check {
#    initial_delay = 10
#    interval      = 5
#    timeout       = 4
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
    tcp_options {
      port = 80
    }
  }
}
# Создание сетевого балансировщика
resource "yandex_lb_network_load_balancer" "vp-nlb-1" {
  name = "network-load-balancer-1"

  listener {
     name = "network-load-balancer-1-listener"
     port = 80
     external_address_spec {
     ip_version = "ipv4"
    }
 }
  attached_target_group {
    target_group_id = yandex_lb_target_group.target-group.id
    healthcheck {
      name = "http"
      interval = 2
      timeout = 1
      unhealthy_threshold = 2
      healthy_threshold = 5
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# Вывод адреса изображения
output "pic-url" {
  value = "https://storage.yandexcloud.net/paint"
}
