locals {
  folder_id = var.folder_id
}
# создание кластера
resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = "k8s-regional"
  network_id = yandex_vpc_network.netology-net.id
  master {
    master_location {
      zone      = yandex_vpc_subnet.subnet-a.zone
      subnet_id = yandex_vpc_subnet.subnet-a.id
    }
    master_location {
      zone      = yandex_vpc_subnet.subnet-b.zone
      subnet_id = yandex_vpc_subnet.subnet-b.id
    }
    master_location {
      zone      = yandex_vpc_subnet.subnet-d.zone
      subnet_id = yandex_vpc_subnet.subnet-d.id
    }
    security_group_ids = [yandex_vpc_security_group.regional-k8s-sg.id]
  }
  service_account_id      = var.service_account_id
  node_service_account_id = local.service_account_id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_iam_service_account" "rkub-account" {
  name        = "regional-k8s-account"
  description = "service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = local.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.rkub-account.id}"
}

 resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = local.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.rkub-account.id}"
}
 resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.rkub-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id = local.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.rkub-account.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ Yandex Key Management Service для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_vpc_security_group" "regional-k8s-sg" {
  name        = "regional-k8s-sg"
  description = "Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Примените ее к кластеру и группам узлов."
  network_id  = yandex_vpc_network.netology-net.id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщик>    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.subnet-a.v4_cidr_blocks, yandex_vpc_subnet.subnet-b.v4_cidr_blocks, yandex_vpc_subnet.subnet-d.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
        v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}
# Создание группы нод для Kubernetes кластера (используя существующую группу виртуальных машин)
resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-regional.id
  name        = "lamp-group-node"
  description = "Node group for Kubernetes cluster"

   version     = "1.27"
  instance_template {
    name = ""
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
    network_interface {
      nat = true
      subnet_ids = [yandex_vpc_subnet.subnet-a.id]
    }
    metadata = {
      "ssh-keys" = var.vms_ssh_root_key  # Используем переменную для SSH-ключей
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
    create = "60m"
  }
}
