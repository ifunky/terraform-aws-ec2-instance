variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'ifunky' or 'WonkaCo'"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "name" {
  type        = string
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "key_pair" {
  type        = string
  description = "Key pair used to when provisioning the instance"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the instance"
  default     = true
}

variable "ami" {
  type        = string
  description = "The AMI to use for the instance"
}

variable "assign_eip_address" {
  type        = bool
  description = "Assign an Elastic IP address to the instance"
  default     = true
}

variable "placement_group" {
  description = "Placement Group to launch the instance in"
  type        = string
  default     = ""
}

variable "user_data" {
  type        = string
  description = "Instance user data. Do not pass gzip-compressed data via this argument"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "The type of the instance"
  default     = "t2.micro"
}

variable "os_type" {
  type        = string
  description = "Type of OS. Either linux or windows"
  default     = "linux"

  validation {
    condition = contains(["linux", "windows"], var.os_type)
    error_message = "Varible os_type must be \"linux\" or \"windows\"."
  }  
}

variable "root_block_device" {
  description = "Customise root block devices of the instance"
  type        = list(map(string))
  default     = [
              {
                volume_type           = "gp2"
                volume_size           = 60
                delete_on_termination = true
              },
              ]
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "ephemeral_block_device" {
  description = "Add Ephemeral volumes to the instance"
  type        = list(map(string))
  default     = []
}

variable "ebs_optimized" {
  type        = bool
  description = "Minimises contention between Amazon EBS I/O and other traffic from your instance"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the instance security group belongs to"
}

variable "subnet" {
  type        = string
  description = "VPC Subnet ID to launch the instance into"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone the instance is launched in. If not set, will be launched in the first AZ of the region"
  default     = ""
}

variable "region" {
  type        = string
  description = "AWS Region to launch the region in, defaults to current context region if not specifed"
  default     = ""
}

variable "security_groups" {
  description = "List of Security Group IDs allowed to connect to the instance"
  type        = list(string)
  default     = []
}

variable "iam_role" {
  type        = string
  description = "IAM instance profile to assign to instance"
}

variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in the VPC"
  default     = null
}

variable "source_dest_check" {
  type        = bool
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs"
  default     = true
}

variable "join_domain" {
  type        = bool
  description = "If true uses SSM document attachment for AD domain joining"
  default     = false
}

variable "join_domain_ssm_document" {
  type        = string
  description = "SSM document name that will be used for joining the domain"
  default     = ""
}

variable "join_domain_ssm_params" {
  type        = map
  description = "Parameters to pass into the join domain SSM document."
  default     = {}
}

variable "detailed_monitoring" {
  type        = bool
  description = "Enables EC2 detailed monitoring"
  default     = false
}

variable "disable_api_termination" {
  type        = bool
  description = "Enable EC2 instance termination protection"
  default     = false
}

variable "ebs_device_name" {
  type        = list(string)
  description = "Name of the EBS device to mount"
  default     = ["/dev/xvdb", "/dev/xvdc", "/dev/xvdd", "/dev/xvde", "/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj", "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt", "/dev/xvdu", "/dev/xvdv", "/dev/xvdw", "/dev/xvdx", "/dev/xvdy", "/dev/xvdz"]
}

variable "ebs_volume_type" {
  type        = string
  description = "The type of EBS volume. Can be standard, gp2 or io1"
  default     = "gp2"
}

variable "ebs_volume_size" {
  type        = number
  description = "Size of the EBS volume in gigabytes"
  default     = 10
}

variable "ebs_iops" {
  type        = number
  description = "Amount of provisioned IOPS. This must be set with a volume_type of io1"
  default     = 0
}

variable "ebs_volume_count" {
  type        = number
  description = "Count of EBS volumes that will be attached to the instance"
  default     = 0
}

variable "delete_on_termination" {
  type        = bool
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}

variable "metadata_options" {
  description = "Set instance metadata options"
  type = object({ enabled=bool, require_session_tokens=bool, http_hop_limit=number })
  default     = {
                enabled                = true
                require_session_tokens = false  # Default to metadata V1
                http_hop_limit         = 1
              }
              
}