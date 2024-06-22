# Создание группы безопасности для Kubernetes
resource "yandex_vpc_security_group" "k8s-main-sg" {
  name        = "k8s-main-sg"
  network_id  = yandex_vpc_network.netology-net.id
  description = "Security group for Kubernetes main resources"
}
# Создание Kubernetes кластера
resource "yandex_kubernetes_cluster" "default" {
  name                  = "my-cluster"
  network_id            = yandex_vpc_network.netology-net.id
  service_account_id    = var.service_account_id
  node_service_account_id = "ajevllle95jhktrpk4ic"
   master {
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.subnet-a.zone
        subnet_id = yandex_vpc_subnet.subnet-a.id
      }

      location {
        zone      = yandex_vpc_subnet.subnet-b.zone
        subnet_id = yandex_vpc_subnet.subnet-b.id
      }

      location {
        zone      = yandex_vpc_subnet.subnet-d.zone
        subnet_id = yandex_vpc_subnet.subnet-d.id
      }
    }
    version = "1.26"
    public_ip = true
    security_group_ids = [yandex_vpc_security_group.k8s-main-sg.id]
    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
    }
  }
 }
}
# Создание группы нод для Kubernetes кластера (используя существующую группу виртуальных машин)
resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = yandex_kubernetes_cluster.default.id
  name        = "lamp-group-node"
  description = "Node group for Kubernetes cluster"
#  instance_group_id = yandex_compute_instance_group.lamp-group.id
  version     = "1.26"
  instance_template {
    platform_id = "standard-v2"

    resources {
      memory        = 2
      cores         = 2
      core_fraction = 5
    }

    boot_disk {
      type = "network-hdd"
      size = 32  # Размер диска установлен на 32 ГБ
    }

    scheduling_policy {
      preemptible = false
    }
  }
  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
  scale_policy {
    auto_scale {
      min     = 1
      max     = 3
      initial = 1
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }
  timeouts {
    create = "120m"
    update = "60m"
    delete = "30m"
 }
}
