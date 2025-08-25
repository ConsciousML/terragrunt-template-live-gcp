locals {
  version = "v0.0.2"
}

stack "vpc_gce" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-gcp//stacks/vpc_gce?ref=${local.version}"
  path   = "infrastructure"

  values = {
    version                = local.version
    network_name           = "vpc"
    subnet_name            = "subnet"
    subnet_cidr            = "10.0.0.0/24"
    region                 = "europe-west1"
    instance_name          = "example-instance"
    machine_type           = "e2-micro"
    zone                   = "europe-west1-b"
    boot_disk_image        = "debian-cloud/debian-11"
    boot_disk_size         = 20
    boot_disk_type         = "pd-standard"
    enable_external_ip     = false
    metadata               = {}
    tags                   = ["example-instance"]
    service_account_email  = null
    service_account_scopes = ["cloud-platform"]
  }
}