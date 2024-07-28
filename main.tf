# Использование существующего сервисного аккаунта
locals {
  service_account_id = var.service_account_id
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
  name = "subnet-a"
  v4_cidr_blocks = ["10.5.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology-net.id
}

resource "yandex_vpc_subnet" "subnet-b" {
  name = "subnet-b"
  v4_cidr_blocks = ["10.6.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology-net.id
}

resource "yandex_vpc_subnet" "subnet-d" {
  name = "subnet-d"
  v4_cidr_blocks = ["10.7.0.0/16"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.netology-net.id
}

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
    address   = "10.5.0.10"
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    address   = "10.6.0.10"
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet-d.id
    address   = "10.7.0.10"
  }
  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }
}
##
resource "yandex_lb_target_group" "ssh_target_group" {
  name      = "ssh-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    address   = "10.5.0.11"
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    address   = "10.6.0.11"
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-d.id
    address   = "10.7.0.11"
  }
}
# Создание группы виртуальных машин
resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-group"
  folder_id          = "b1gpoeqn2q7if0pboa4u"
  service_account_id = var.service_account_id
  instance_template {
    platform_id = "standard-v2"
        resources {
      cores  = 2
      memory = 2
      core_fraction = 5
      }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    metadata = {
      user-data = file("/home/vagrant/diplom/cloud.yaml")
    }

    scheduling_policy {
         preemptible = true
      }
     network_interface {
       nat = true
       subnet_ids = [
        yandex_vpc_subnet.subnet-a.id,
        yandex_vpc_subnet.subnet-b.id,
        yandex_vpc_subnet.subnet-d.id
      ]
    }
 }
     scale_policy {
      fixed_scale {
        size = 3
    }
  }
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion = 2
  }
  health_check {
    interval      = 10
    timeout       = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    tcp_options {
      port = 80
    }
  }
}

# Создание сетевого балансировщика
resource "yandex_lb_network_load_balancer" "my-load-balancer" {
  name = "my-load-balancer"
 listener {
     name = "http-listener"
     port = 80
     external_address_spec {
     ip_version = "ipv4"
    }
 }
  listener {
    name = "ssh-listener"
    port = 22
    target_port = 22
    external_address_spec {
    ip_version = "ipv4"
    }
 }
  attached_target_group {
    target_group_id = yandex_lb_target_group.target-group.id

    healthcheck {
      name = "http"
      interval = 10
      timeout = 5
      unhealthy_threshold = 2
      healthy_threshold = 5
      http_options {
        port = 80
        path = "/"
      }
    }
 }
 attached_target_group {
   target_group_id = yandex_lb_target_group.ssh_target_group.id
    healthcheck {
      name               = "ssh"
      interval           = 10
      timeout            = 5
      unhealthy_threshold = 2
      healthy_threshold  = 2
      tcp_options {
        port = 22
      }
    }
  }
}

# Вывод адреса изображения
output "pic-url" {
  value = "https://storage.yandexcloud.net/paint"
}
