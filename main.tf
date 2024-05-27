# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "YOUR_ORG"
    workspaces = {

      name         = "learn-terraform-data-sources-vpc"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    // NOT exist anymore
    /*values = ["amzn2-ami-hvm-*-x86_64-gp2"]*/
    values = ["amzn2-ami-*-hvm-*x86_64-*"]
  }
}

provider "aws" {
  # 1. hardcoded
  # region = "us-east-1"
  # 2. from dataSource
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.0"

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-tutorial-example"

  internal = false

  # from dataSource
  security_groups = data.terraform_remote_state.vpc.outputs.lb_security_group_ids
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  number_of_instances = length(aws_instance.app)
  instances           = aws_instance.app.*.id

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
}

resource "aws_instance" "app" {
  # 1. hardcoded
  #ami = "ami-04d29b6f966df1537"
  # 2. from datasource
  ami = data.aws_ami.amazon_linux.id

  # Apply functions on dataSources
  count = var.instances_per_subnet * length(data.terraform_remote_state.vpc.outputs.private_subnet_ids)

  instance_type = var.instance_type

  # From HCP, VPC workspace
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_ids[count.index % length(data.terraform_remote_state.vpc.outputs.private_subnet_ids)]
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.app_security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
    EOF
}
