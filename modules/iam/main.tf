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

resource "aws_config_delivery_channel" "example" {
  name           = "example_delivery_channel"
  s3_bucket_name = aws_s3_bucket.example.bucket
  depends_on     = [aws_config_configuration_recorder.example]
}

resource "aws_s3_bucket" "example" {
  bucket        = "example-awsconfig-s3-bucket"
  force_destroy = true
}


resource "aws_iam_role" "example" {
  name = "example_iam_role"

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

resource "aws_iam_role_policy" "example" {
  name = "awsconfig-example"
  role = aws_iam_role.example.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.example.arn}",
        "${aws_s3_bucket.example.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_config_config_rule" "iam_user_mfa" {

    name = "MFA_Enabled_Config_Rule"
    description = "A config rule that checks whether the AWS IAM users have MFA enabled."

    maximum_execution_frequency = "One_Hour"

    source {
        owner = "AWS"
        source_identifier = "IAM_USER_MFA_ENABLED"
    }
    scope {
        compliance_resource_types = []
    }

    depends_on = [aws_config_configuration_recorder.example]

}
