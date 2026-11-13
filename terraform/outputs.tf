output "network_id" {
  description = "ID of the Kubernetes VPC network"
  value       = yandex_vpc_network.k8s.id
}

output "subnet_id" {
  description = "ID of the Kubernetes subnet"
  value       = yandex_vpc_subnet.k8s.id
}

output "security_group_id" {
  description = "ID of the Kubernetes security group"
  value       = yandex_vpc_security_group.k8s.id
}

output "nodes" {
  description = "Kubernetes nodes with their private and public IP addresses"

  value = {
    for name, instance in yandex_compute_instance.node :
    name => {
      id         = instance.id
      private_ip = instance.network_interface[0].ip_address
      public_ip  = instance.network_interface[0].nat_ip_address
    }
  }
}

output "master_public_ip" {
  description = "Public IP of the Kubernetes control plane"
  value       = yandex_compute_instance.node["k8s-master"].network_interface[0].nat_ip_address
}
