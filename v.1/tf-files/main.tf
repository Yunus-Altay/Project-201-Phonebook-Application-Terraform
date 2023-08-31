terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "web_server_lt" {
  name                   = "${var.tag_name}-server"
  image_id               = data.aws_ami.amzn-linux-2023-ami.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sec_gr.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.tag_name}-server"
    }
  }
  user_data = base64encode(templatefile("${path.module}/script.sh", {
    my_db_url = aws_db_instance.web_server_db_instance.address
  }))


  depends_on = [aws_db_instance.web_server_db_instance] 
}

resource "aws_lb_target_group" "web_server_tg" {
  name     = "${var.tag_name}-target-gr"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
  }
  tags = {
    Name = "${var.tag_name}-target-gr"
  }
}

resource "aws_lb" "web_server_alb" {
  name               = "${var.tag_name}-target-alb"
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb_sec_gr.id]
  subnets            = var.subnet_id_list
  tags = {
    Environment = "${var.tag_name}-alb"
  }
}

resource "aws_lb_listener" "web_server_listener" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_tg.arn
  }
  tags = {
    Name = "${var.tag_name}-alb-listener"
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name = "${var.tag_name}-asg"
  vpc_zone_identifier       = var.subnet_id_list
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  default_cooldown          = 30
  default_instance_warmup   = 90
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.web_server_tg.arn]
  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.tag_name}-server"
    propagate_at_launch = true
  }
}

resource "aws_db_subnet_group" "web_server_db_subnet_group" {
  name        = "${var.tag_name}_db_subnet_group"
  description = "Subnets available for the RDS DB Instance"
  subnet_ids  = var.subnet_id_list
  tags = {
    Name = "${var.tag_name}_db_subnet_group"
  }
}

resource "aws_db_instance" "web_server_db_instance" {
  allocated_storage           = 20
  allow_major_version_upgrade = false
  backup_retention_period     = 0
  db_name                     = var.db_name
  db_subnet_group_name        = aws_db_subnet_group.web_server_db_subnet_group.name
  delete_automated_backups    = true
  engine                      = "mysql"
  engine_version              = "8.0.32"
  instance_class              = "db.t2.micro"
  identifier                  = "${lower(var.tag_name)}-db-instance"
  username                    = var.db_username
  password                    = var.db_password
  maintenance_window          = "Mon:03:00-Mon:04:00"
  max_allocated_storage       = 30
  multi_az                    = false
  port                        = 3306
  publicly_accessible         = true
  skip_final_snapshot         = true
  vpc_security_group_ids = [aws_security_group.rds_sec_gr.id]
  tags = {
    Name = "${var.tag_name}_db_instance"
  }
}
