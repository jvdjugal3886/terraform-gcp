# Resource block to create Google Cloud SQL instances
resource "google_sql_database_instance" "pg_instance" {

  # Use `for_each` to iterate over the `sql_instances` variable and create a Cloud SQL instance for each entry
  for_each = { for idx, instance in var.sql_instances : idx => instance }

  # Name of the Cloud SQL instance, derived from the `name` attribute in the `sql_instances` variable
  name = "${each.value.name}-${var.env}"

  # Database version (e.g., POSTGRES_13), derived from the `database_version` attribute in the `sql_instances` variable
  database_version = each.value.database_version

  # Region where the Cloud SQL instance will be deployed, derived from the `region` attribute in the `sql_instances` variable
  region = each.value.region

  # Project ID where the Cloud SQL instance will be created, provided by the `project_id` variable
  project = var.project_id

  # Disable deletion protection to allow the instance to be deleted (set to `true` for production environments)
  deletion_protection = false


  # Settings block for configuring the Cloud SQL instance
  settings {
    tier              = each.value.tier
    availability_type = each.value.availability_type
    disk_size         = each.value.disk_size
    disk_type         = each.value.disk_type

    ip_configuration {
      ipv4_enabled    = each.value.enable_public_ip
      private_network = each.value.enable_private_ip ? each.value.vpc_network : null
    }

    maintenance_window {
      day          = each.value.maintenance_window.day
      hour         = each.value.maintenance_window.hour
      update_track = each.value.maintenance_window.update_track
    }
  }
}

# Resource block to create databases within the Cloud SQL instances
resource "google_sql_database" "database" {
  for_each = { for idx, instance in var.sql_instances : idx => instance }


  # Project ID where the database will be created
  project = var.project_id

  # Name of the database to be created
  name = "${each.value.databases[0].name}-${var.env}"

  # Reference to the parent Cloud SQL instance
  instance = google_sql_database_instance.pg_instance[each.key].name
}
# Resource block to create database users for the Cloud SQL instances
resource "google_sql_user" "db_user" {
  for_each = { for idx, instance in var.sql_instances : idx => instance }

  # Project ID where the user will be created
  project = var.project_id

  # Username for the database user
  name = "${each.value.users[0].name}-${var.env}"

  # Reference to the parent Cloud SQL instance
  instance = google_sql_database_instance.pg_instance[each.key].name

  # Password for the database user
  password = each.value.users[0].password
}
