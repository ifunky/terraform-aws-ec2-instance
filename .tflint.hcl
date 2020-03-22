config {
  module = false
  deep_check = false
  force = false
}

rule "terraform_module_pinned_source" {
  enabled = false
}
rule "aws_ssm_association_invalid_name" {
  enabled = false
}
