terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "< 4.0"
      configuration_aliases = [aws.shared]
    }
  }
  experiments = [module_variable_optional_attrs]
}
