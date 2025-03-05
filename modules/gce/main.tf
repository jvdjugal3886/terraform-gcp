resource "google_compute_instance" "default" {
  # Iterate over the instances defined in the variable `instances`

  for_each = {
    for idx, instance in var.instances : instance.name => instance
  }

  # Instance basic configurations

  name         = "${each.value.name}-${var.env}"
  machine_type = each.value.machine_type
  zone         = each.value.zone
  project      = var.project_id

  # Define the boot disk with initialization parameters
  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.disk_size
      type  = each.value.disk_type
    }
  }

  # Configure network settings
  network_interface {
    network = each.value.network
    # Add a public IP if enabled in the configuration

    dynamic "access_config" {
      for_each = each.value.public_ip ? [1] : []
      content {
        # Ephemeral public IP
      }
    }
  }
  # Define scheduling options for the instance

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  labels = merge(
    {
      "managed-by" = "terraform"
    },
    each.value.labels
  )
}
