variable "zone" {
  description = "Availability zone for Kubernetes nodes"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_source_cidr" {
  description = "External IP allowed to connect to nodes"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

variable "image_id" {
  description = "Ubuntu 22.04 LTS image ID"
  type        = string
  default     = "fd8nu6v2r30ugg65pb7t"
}
