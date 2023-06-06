data "aws_caller_identity" "default" {}
data "aws_region" "default" {}
data "aws_subnet" "default" {
  id = var.subnet
}

locals {
  instance_count       = var.enabled ? 1 : 0
  region               = var.region != "" ? var.region : data.aws_region.default.name
  availability_zone    = var.availability_zone != "" ? var.availability_zone : data.aws_subnet.default.availability_zone
  ebs_iops             = var.ebs_volume_type == "io1" ? var.ebs_iops : "0"
  ami                  = var.ami
  metadata_enabled     = var.metadata_options.enabled ? "enabled" : "disabled"
  metadata_tokens      = var.metadata_options.require_session_tokens ? "required" : "optional" #tfsec:ignore:GEN002
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label?ref=main"
  namespace  = var.namespace
  stage      = var.stage
  attributes = var.attributes
  delimiter  = var.delimiter
  enabled    = var.enabled
  tags       = var.tags
}

resource "aws_instance" "default" {
  count                       = local.instance_count
  ami                         = local.ami
  availability_zone           = local.availability_zone
  instance_type               = var.instance_type
  ebs_optimized               = var.ebs_optimized
  disable_api_termination     = var.disable_api_termination
  user_data                   = templatefile("${path.module}/userdata_${var.os_type}.tmpl", { user_data = var.user_data, block_devices = var.ebs_block_device })
  iam_instance_profile        = var.iam_role
  associate_public_ip_address = var.associate_public_ip_address #tfsec:ignore:AWS012
  key_name                    = var.key_pair
  subnet_id                   = var.subnet
  monitoring                  = var.detailed_monitoring
  private_ip                  = var.private_ip
  source_dest_check           = var.source_dest_check
  vpc_security_group_ids      =  var.security_groups
  placement_group             = var.placement_group

 dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  tags                    = merge(tomap({ "Name" = var.name}), var.tags)
  volume_tags             = var.tags

  metadata_options {
    http_endpoint               = local.metadata_enabled
    http_tokens                 = local.metadata_tokens
    http_put_response_hop_limit = var.metadata_options.http_hop_limit
  }

  lifecycle {
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments "root_block_device" and "ebs_block_device"
    ignore_changes = [
      root_block_device,
      ebs_block_device,
      user_data
    ]
  }
}

resource "aws_eip" "default" {
  count    = var.associate_public_ip_address && var.assign_eip_address && var.enabled ? 1 : 0
  instance = aws_instance.default[count.index].id
  vpc      = true
  tags     = var.tags
}

resource "aws_ebs_volume" "default" {
  count             = var.ebs_volume_count
  availability_zone = local.availability_zone
  size              = var.ebs_volume_size
  iops              = local.ebs_iops
  type              = var.ebs_volume_type
  tags              = var.tags
}

resource "aws_volume_attachment" "default" {
  count       = var.ebs_volume_count
  device_name = var.ebs_device_name[count.index]
  volume_id   = aws_ebs_volume.default.*.id[count.index]
  instance_id = aws_instance.default[count.index].id
}

resource "aws_ssm_association" "default" {
  count      = var.join_domain && var.enabled ? 1 : 0
	name       = var.join_domain_ssm_document
  parameters = var.join_domain_ssm_params

  targets {
    key    = "InstanceIds"
    values = [aws_instance.default[count.index].id]
  }
}