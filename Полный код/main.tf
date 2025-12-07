resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-init.yml")

  vars = {
    ssh_key = var.vms_ssh_root_key
  }
}

module "marketing_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name       = "marketing"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = [var.default_zone]
  subnet_ids     = [yandex_vpc_subnet.develop.id]
  instance_name  = "marketing"
  instance_count = 1

  image_family = "ubuntu-2004-lts"
  public_ip    = true

  labels = {
    project = "marketing"
  }

  metadata = {
    user-data          = data.template_file.cloud_init.rendered
    serial-port-enable = 1
  }
}

module "analytics_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name       = "analytics"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = [var.default_zone]
  subnet_ids     = [yandex_vpc_subnet.develop.id]
  instance_name  = "analytics"
  instance_count = 1

  image_family = "ubuntu-2004-lts"
  public_ip    = true

  labels = {
    project = "analytics"
  }

  metadata = {
    user-data          = data.template_file.cloud_init.rendered
    serial-port-enable = 1
  }
}
