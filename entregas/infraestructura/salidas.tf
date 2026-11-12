output "bucket" {
  value = aws_s3_bucket.entregas.bucket
}

output "base_datos" {
  value = aws_glue_catalog_database.entregas.name
}

output "tabla" {
  value = aws_glue_catalog_table.entregas.name
}

output "workgroup" {
  value = aws_athena_workgroup.entregas.name
}

output "region" {
  value = var.region
}
