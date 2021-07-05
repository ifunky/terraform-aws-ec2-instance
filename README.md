<!-- Auto generated file -->

# Create AWS EC2 Linux or Windows Servers


 [![Build Status](https://circleci.com/gh/ifunky/terraform-aws-ec2-instance.svg?style=svg)](https://circleci.com/gh/ifunky/terraform-aws-ec2-instance) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This module creates Linux or Windows EC2 instances.

## Features

### Linux/Windows Server

- Optionally set an Elastic IP (EIP)
- Specify an IAM role
- Assign security groups
- Optionally join a domain using SSM documents (see notes below)
- Attach 1 or more additional EBS volumes

### Instance Meta Data Service Support
- Support metadata IMDSv1 and IMDSv2
- For better security the default is IMDSv2.  Using IMDSv1 will show up as "High" in SecurityHub

### User Data
- Specify optional user data scripts

## Custom User Data
Add your own server specifc user data scripts (see full example below) that will be executed after the disk intialisation.  To debug the scripts see the 
following folder on the running instance: C:\ProgramData\Amazon\EC2-Windows\Launch\Log

## Domain Joining
In order to join a domain as part of provisioning an Active Directory and SSM document must be in place already.  
When using AWS AD sharing a default SSM document will be created that can be used.

## Block Device mapping
This module follows the AWS conventions where by `\dev\sda1` is defined as the root device and all other ebs volumes use the recommended names `xvd[f-z] *`
When creating addtional ebs volumes you can specify any variables as described in the Terraform docs: https://www.terraform.io/docs/providers/aws/r/instance.html#block-devices

For Windows you can specify the following drive properties as well:
- volume_letter
- volume_name

For example:
```hcl
 ebs_block_device = [
            {
              volume_letter         = "E"
              volume_name           = "Data"
              device_name           = "xvdg"
              volume_type           = "gp2"
              volume_size           = 20
              delete_on_termination = true
            }
  ]
```



## Usage
```hcl
module "ec2_myserver" {
  source = "git::https://github.com/ifunky/terraform-aws-ec2-instance?ref=master"

  ami             = data.aws_ami.linux.id
  iam_role        = "iam_role_name"
  key_pair        = "${var.useful_thing}"
  instance_type   = "t3a.small"
  vpc_id          = "a-12345678"
  security_groups = ["sg_windows"]
  subnet          = "i-3r4t555"
  name            = "My_Server"
  namespace       = "ifunky"
  stage           = "dev"
  tags = {
    Terraform = "true"
  }
}
```
Full example
```hcl
module "ec2_myserver" {
  source = "git::https://github.com/ifunky/terraform-aws-ec2-instance?ref=master"

  ami             = data.aws_ami.linux.id
  iam_role        = "iam_role_name"    
  key_pair        = var.my_key
  instance_type   = "t3a.small"
  vpc_id          = "a-e343434334"
  security_groups = ["sg_windows"]
  subnet          = "i-573443ww"
  name            = "My_Server"
  namespace       = "ifunky"
  stage           = "dev"

  metadata_options {
    enabled                 = true
    require_session_tokens  = true # Use metadata service V2
    http_hop_limit          = 1
  }

  user_data       =<<EOF
      echo "test" > c:\windows\temp\log1.log
      echo "test2" > c:\windows\temp\log2.log
      EOF

  join_domain               = true
  join_domain_ssm_document  = "awsconfig_Domain_d-34343434_ifunky.com"
  join_domain_ssm_params    = {
    ServerName = "MyServerName"
  }

  ebs_block_device = [
            {
              volume_letter         = "E"
              volume_name           = "Data"
              device_name           = "xvdg"
              volume_type           = "gp2"
              volume_size           = 20
              delete_on_termination = true
            },
            {
              volume_letter         = "F"
              volume_name          = "Logs"
              device_name           = "xvdh"
              volume_type           = "gp2"
              volume_size           = 25
              delete_on_termination = true
            },
            ]

  tags = {
    Terraform = "true"
  }
}
```


## Makefile Targets
The following targets are available: 

```
createdocs/help                Create documentation help
polydev/createdocs             Run PolyDev createdocs directly from your shell
polydev/help                   Help on using PolyDev locally
polydev/init                   Initialise the project
polydev/validate               Validate the code
polydev                        Run PolyDev interactive shell to start developing with all the tools or run AWS CLI commands :-)
```
# Module Specifics

Core Version Constraints:
* `~> 0.13.5`

Provider Requirements:
* **aws:** `~> 3.0`

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
* `metadata_options` (default `{"enabled":true,"http_hop_limit":1,"require_session_tokens":false}`): Set instance metadata options
* `name` (required): Solution name, e.g. 'app' or 'jenkins'
* `namespace` (required): Namespace, which could be your organization name or abbreviation, e.g. 'ifunky' or 'WonkaCo'
* `os_type` (default `"linux"`): Type of OS. Either linux or windows
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




## Related Projects

Here are some useful related projects.

- [PolyDev](https://github.com/ifunky/polydev) - PolyDev repo and setup guide





## References

For more information please see the following links of interest: 

- [AWS Windows User Data](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-user-data.html) - AWS Windows User Data guide
- [AWS Windows Device Mapping](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-volumes.html#windows-volume-mapping) - AWS Windows Volume Mapping
- [AWS Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) - Metadata Official Docs
- [Terraform EC2 Instance](https://www.terraform.io/docs/providers/aws/r/instance.html) - Terraform EC2 documentation

