# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}


data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "${var.env}--acsproject-group21"        // Bucket from where to GET Terraform State
    key    = "${var.env}-network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                            // Region where bucket created
  }
}

data "terraform_remote_state" "webservers" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "${var.env}--acsproject-group21"        // Bucket from where to GET Terraform State
    key    = "${var.env}-webservers/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                            // Region where bucket created
  }
} 
resource "aws_lb""alb"{
  name = "${var.prefix}-${var.env}-ALB"
  load_balancer_type = "application"
  internal = false
  security_groups             = data.terraform_remote_state.webservers.outputs.security_group_web_sg[*]
  subnets = data.terraform_remote_state.network.outputs.public_subnet_ids[*] 
  enable_cross_zone_load_balancing = true
  
}
resource "aws_lb_target_group""targetgroup"{
  health_check{
  interval = 10
  path = "/"
  protocol = "HTTP"
  timeout = 5
  healthy_threshold = 5
  unhealthy_threshold = 2
  }
  name = "${var.prefix}-${var.env}-TargetGroup"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  
}
resource "aws_lb_listener" "lb_listener" { 
  load_balancer_arn = aws_lb.alb.arn 
  port = 80 
  protocol = "HTTP" 
  default_action {
  type = "forward"
  target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}

resource "aws_lb_target_group_attachment""targetatt"{
  count = var.num_count
  target_group_arn = "${aws_lb_target_group.targetgroup.arn}"
  target_id = data.terraform_remote_state.webservers.outputs.instance_id[count.index]
  #register_targets = data.terraform_remote_state.webservers.outputs.instance_id[1]
  port = 80
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}
