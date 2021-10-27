config {
  module = false
  force = false
}

plugin "aws" {
  enabled = true
  deep_check = false
}

rule "terraform_module_pinned_source" {
  enabled = false
}
rule "aws_ssm_association_invalid_name" {
  enabled = false
}
