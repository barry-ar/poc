resource "google_compute_instance" "default" {
  count         = var.type == "simple" ? 1 : 0
  name         = "test"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  tags = ["env", "algoan"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    khirina_ssh = "my-ssh-key:${file("~/.ssh/id_rsa.pub")}"
  }

}