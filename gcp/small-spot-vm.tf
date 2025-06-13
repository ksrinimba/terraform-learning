# This code is compatible with Terraform 4.25.0 and versions that are backward compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

resource "google_compute_instance" "instance-20250525-072904" {
  boot_disk {
    auto_delete = true
    device_name = "instance-20250525-072904"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20250513"
      size  = 10
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
  }

  machine_type = "e2-micro"

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "srinivaskambhampati:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfqAsDlVinGipNlwRwajlCI3vhJazA9VZsWzr+iSDmBbpZWs4Q6Ks5G5f06fOxAULIdpEVzIJfgNNbvys5znUHLJTzrzJFL75+DqziVGoFtBTfhKkQhPQIuLef7gx9b3Nf1rGRMeXe7s3GPUOPig0dxYIX6s7fY1xCagC0yRba7ngauEu28k3oRpogGdOGzf+Otqk4jOfCLE+k7KtnfbH3WVp4HNDE1NbRI1pbBGQnhMmA55wuqAP38GWnM7T5YVIzEu+Gc9LiPmzKpFjk7aiIvu4vxYH5a/bz98eqMg7/eJsid0Ef/LY9ydfpKpiHRViLTDJmQc/p65d5yKzPV5ezh5+FiZe4Zo4gmdXo90whU1reQ0RGOOz1XGpvH5H95vqWOFCtmRHemARzw/N4ROnWZDnLLg0Ovyn6YChHP5Hksw3K2vn01n5O31wV5ET1N4dJ6IxtdihIl4eTGjdba2UTZqP3xJGsOn+m1pf69/hXG8aj3H18WIUCf0xQx2O6KEM= srinivaskambhampati@srinivass-MacBook-Air.local"
  }

  name = "instance-20250525-072904"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/cohesive-gadget-460703-k0/regions/us-central1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = false
    provisioning_model  = "SPOT"
  }

  service_account {
    email  = "1047174251265-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = false
    enable_secure_boot          = false
    enable_vtpm                 = false
  }

  tags = ["http-server", "lb-health-check"]
  zone = "us-central1-c"
}

module "ops_agent_policy" {
  source          = "github.com/terraform-google-modules/terraform-google-cloud-operations/modules/ops-agent-policy"
  project         = "cohesive-gadget-460703-k0"
  zone            = "us-central1-c"
  assignment_id   = "goog-ops-agent-v2-x86-template-1-4-0-us-central1-c"
  agents_rule = {
    package_state = "installed"
    version = "latest"
  }
  instance_filter = {
    all = false
    inclusion_labels = [{
      labels = {
        goog-ops-agent-policy = "v2-x86-template-1-4-0"
      }
    }]
  }
}

