# Output block to provide the names of all created SQL instances
output "sql_instance_names" {
  description = "Names of the created SQL instances"
  # List comprehension to get the name attribute from each SQL instance
  value = [for instance in google_sql_database_instance.pg_instance : instance.name]
}
# Output block to provide the names of all created SQL databases
output "sql_database_names" {
  description = "Names of the created SQL databases"
  value       = [for database in google_sql_database.database : database.name]
}

output "sql_user_names" {
  description = "Names of the created SQL users"
  value       = [for user in google_sql_user.db_user : user.name]
}

output "public_ips" {
  value = { for k, v in google_sql_database_instance.pg_instance : k => v.public_ip_address }
}

output "private_ips" {
  value = { for k, v in google_sql_database_instance.pg_instance : k => v.private_ip_address }
}

