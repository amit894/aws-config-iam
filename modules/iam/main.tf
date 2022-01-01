terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.34.0"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_config_configuration_recorder" "example" {
  name     = "example_configuration_recorder"
  role_arn = aws_iam_role.example.arn
}


resource "aws_iam_role" "example" {
  name = "awsconfig_example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_config_config_rule" "iam_user_mfa" {

    name = "MFA_Enabled_Config_Rule"
    description = "A config rule that checks whether the AWS IAM users have MFA enabled."

    maximum_execution_frequency = "Six_Hours"

    source {
        owner = "AWS"
        source_identifier = "IAM_USER_MFA_ENABLED"
    }
    scope {
        compliance_resource_types = []
    }

    depends_on = [aws_config_configuration_recorder.example]

}
