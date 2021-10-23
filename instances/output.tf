output "public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}

output "s3_tags" {
  value = aws_s3_bucket.flugel_bucket_test.tags
}