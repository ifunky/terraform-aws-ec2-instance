# Module Specifics

Core Version Constraints:
* `~> 0.12.20`

Provider Requirements:
* **aws:** `~> 2.16`

## Input Variables
* `ami` (required): The AMI to use for the instance
* `assign_eip_address` (default `true`): Assign an Elastic IP address to the instance
* `associate_public_ip_address` (default `true`): Associate a public IP address with the instance
* `attributes` (required): Additional attributes (e.g. `1`)
* `availability_zone` (required): Availability Zone the instance is launched in. If not set, will be launched in the first AZ of the region
* `delete_on_termination` (default `true`): Whether the volume should be destroyed on instance termination
* `delimiter` (default `"-"`): Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`
* `detailed_monitoring` (required): Enables EC2 detailed monitoring
* `disable_api_termination` (required): Enable EC2 instance termination protection
* `ebs_block_device` (required): Additional EBS block devices to attach to the instance
* `ebs_device_name` (default `["/dev/xvdb","/dev/xvdc","/dev/xvdd","/dev/xvde","/dev/xvdf","/dev/xvdg","/dev/xvdh","/dev/xvdi","/dev/xvdj","/dev/xvdk","/dev/xvdl","/dev/xvdm","/dev/xvdn","/dev/xvdo","/dev/xvdp","/dev/xvdq","/dev/xvdr","/dev/xvds","/dev/xvdt","/dev/xvdu","/dev/xvdv","/dev/xvdw","/dev/xvdx","/dev/xvdy","/dev/xvdz"]`): Name of the EBS device to mount
* `ebs_iops` (required): Amount of provisioned IOPS. This must be set with a volume_type of io1
* `ebs_optimized` (required): Minimises contention between Amazon EBS I/O and other traffic from your instance
* `ebs_volume_count` (required): Count of EBS volumes that will be attached to the instance
* `ebs_volume_size` (default `10`): Size of the EBS volume in gigabytes
* `ebs_volume_type` (default `"gp2"`): The type of EBS volume. Can be standard, gp2 or io1
* `enabled` (default `true`): Set to false to prevent the module from creating any resources
* `environment` (required): Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'
* `ephemeral_block_device` (required): Add Ephemeral volumes to the instance
* `iam_role` (required): IAM instance profile to assign to instance
* `instance_type` (default `"t2.micro"`): The type of the instance
* `join_domain` (required): If true uses SSM document attachment for AD domain joining
* `join_domain_ssm_document` (required): SSM document name that will be used for joining the domain
* `join_domain_ssm_params` (required): Parameters to pass into the join domain SSM document.
* `key_pair` (required): Key pair used to when provisioning the instance
* `name` (required): Solution name, e.g. 'app' or 'jenkins'
* `namespace` (required): Namespace, which could be your organization name or abbreviation, e.g. 'ifunky' or 'WonkaCo'
* `placement_group` (required): Placement Group to launch the instance in
* `private_ip` (required): Private IP address to associate with the instance in the VPC
* `region` (required): AWS Region to launch the region in, defaults to current context region if not specifed
* `root_block_device` (default `[{"delete_on_termination":true,"volume_size":60,"volume_type":"gp2"}]`): Customise root block devices of the instance
* `security_groups` (required): List of Security Group IDs allowed to connect to the instance
* `source_dest_check` (default `true`): Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs
* `stage` (required): Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'
* `subnet` (required): VPC Subnet ID to launch the instance into
* `tags` (required): Additional tags (e.g. `map('BusinessUnit','XYZ')`
* `user_data` (required): Instance user data. Do not pass gzip-compressed data via this argument
* `vpc_id` (required): The ID of the VPC that the instance security group belongs to

## Output Values
* `ebs_ids`: IDs of EBSs
* `id`: ID of the instance
* `private_dns`: Private DNS of instance
* `private_ip`: Private IP of instance
* `public_dns`: Public DNS of instance (or DNS of EIP)
* `public_ip`: Public IP of instance (or EIP)

## Managed Resources
* `aws_ebs_volume.default` from `aws`
* `aws_eip.default` from `aws`
* `aws_instance.default` from `aws`
* `aws_ssm_association.default` from `aws`
* `aws_volume_attachment.default` from `aws`

## Data Resources
* `data.aws_caller_identity.default` from `aws`
* `data.aws_region.default` from `aws`
* `data.aws_subnet.default` from `aws`

## Child Modules
* `label` from `git::https://github.com/cloudposse/terraform-null-label?ref=master`

