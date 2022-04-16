# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "${var.env}-acsproject-group21"        // Bucket from where to GET Terraform State
    key    = "${var.env}-network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                            // Region where bucket created
  }
}

data "terraform_remote_state" "webservers" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "${var.env}-acsproject-group21"        // Bucket from where to GET Terraform State
    key    = "${var.env}-webservers/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                            // Region where bucket created
  }
}


resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "Launch configuration for ${var.env}"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
  key_name                    = "${var.prefix}"
  security_groups             = data.terraform_remote_state.webservers.outputs.security_group_web_sg[*]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "ASG for ${var.prefix} ${var.env}"
  vpc_zone_identifier      = data.terraform_remote_state.network.outputs.private_subnet_ids[*]
  launch_configuration = aws_launch_configuration.as_conf.name
  desired_capacity     = 2
  min_size             = 1
  max_size             = 2
 /* key_name = "${var.prefix}"
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index]
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = false
  user_data                   = file("${path.module}/install_httpd.sh")

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }


  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-${var.env} Amazon-Linux ${count.index} "
    }
  )
}*/
 #target_group_arns = module.aws_lb_target_group.targetgroup.arn
  

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_policy" "scale_down" {
  name = "${var.prefix} ${var.env} down"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1
  cooldown = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description = "Monitors CPU utilization for ASG"
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
  alarm_name = "scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  threshold = "5"
  evaluation_periods = "2"
  period = "120"
  statistic = "Average" 
  dimensions = {
  AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name = "${var.prefix} ${var.env} up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
  cooldown = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description = "Monitors CPU utilization for ASG"
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
  alarm_name = "scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  threshold = "10"
  evaluation_periods = "2"
  period = "120"
  statistic = "Average" 
  dimensions = {
  AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}


# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}
