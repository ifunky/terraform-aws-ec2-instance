output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = var.enabled ? join("", aws_eip.default.*.public_ip) : ""
}

output "private_ip" {
  description = "Private IP of instance"
  value       = join("", aws_instance.default.*.private_ip)
}

output "private_dns" {
  description = "Private DNS of instance"
  value       = join("", aws_instance.default.*.private_dns)
}

output "public_dns" {
  description = "Public DNS of instance (or DNS of EIP)"
  value       =  var.enabled ? join("", aws_eip.default.*.public_dns) : ""
}

output "id" {
  description = "ID of the instance"
  value       = join("", aws_instance.default.*.id)
}

output "ebs_ids" {
  description = "IDs of EBSs"
  value       = aws_ebs_volume.default.*.id
}
