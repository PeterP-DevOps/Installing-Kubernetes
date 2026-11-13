# Cloud network

resource "yandex_vpc_network" "k8s" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s" {
  name           = "k8s-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# Security Group

resource "yandex_vpc_security_group" "k8s" {
  name       = "k8s-security-group"
  network_id = yandex_vpc_network.k8s.id


  ingress {
    protocol       = "TCP"
    description    = "SSH access from administrator"
    port           = 22
    v4_cidr_blocks = [var.ssh_source_cidr]
  }

  # Kubernetes API: external administration
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API access"
    port           = 6443
    v4_cidr_blocks = [var.ssh_source_cidr]
  }

  # NodePort: access to test applications
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes NodePort range"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = [var.ssh_source_cidr]
  }

  # All node-to-node traffic inside the private subnet
  ingress {
    protocol       = "ANY"
    description    = "Internal Kubernetes node communication"
    v4_cidr_blocks = [var.subnet_cidr]
  }

  # Outbound traffic
  egress {
    protocol       = "ANY"
    description    = "Allow outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Kubernetes nodes

locals {
  nodes = {
    k8s-master = {
      role      = "master"
      cores     = 2
      memory    = 4
      disk_size = 30
    }

    k8s-worker-1 = {
      role      = "worker"
      cores     = 2
      memory    = 4
      disk_size = 25
    }

    k8s-worker-2 = {
      role      = "worker"
      cores     = 2
      memory    = 4
      disk_size = 25
    }

    k8s-worker-3 = {
      role      = "worker"
      cores     = 2
      memory    = 4
      disk_size = 25
    }

    k8s-worker-4 = {
      role      = "worker"
      cores     = 2
      memory    = 4
      disk_size = 25
    }
  }
}

resource "yandex_compute_instance" "node" {
  for_each = local.nodes

  name        = each.key
  hostname    = each.key
  zone        = var.zone
  platform_id = "standard-v3"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = each.value.disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
  }

  allow_stopping_for_update = true

  labels = {
    project = "kubernetes"
    role    = each.value.role
  }
}
