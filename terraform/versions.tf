
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.170.0"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}
