# Create the first Target Group for Images
resource "aws_lb_target_group" "images_tg" {
  name     = "images-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "images-tg"
  }
}

# Create the second Target Group for Videos
resource "aws_lb_target_group" "videos_tg" {
  name     = "videos-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "videos-tg"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]  
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

# Create a listener for the Application Load Balancer
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

# Add rules to route traffic to Images Target Group
resource "aws_lb_listener_rule" "images_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.images_tg.arn
  }

  condition {
    path_pattern {
      values = ["/images/*"]
    }
  }
}

# Add rules to route traffic to Videos Target Group
resource "aws_lb_listener_rule" "videos_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.videos_tg.arn
  }

  condition {
    path_pattern {
      values = ["/videos/*"]
    }
  }
}

# Launch Configuration for Images instances
resource "aws_launch_configuration" "images_lc" {
  name          = "images-launch-configuration"
  image_id      = "ami-066784287e358dad1"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }

  security_groups = [aws_security_group.my_security_group.id]  # Add your security group IDs here

  user_data = <<-EOF
                #!/bin/bash
                echo "Starting Images Instance"
                
                # Install Apache
                sudo yum update -y
                sudo yum install -y httpd

                # Start Apache and enable it to start on boot
                sudo systemctl start httpd
                sudo systemctl enable httpd

                # Create a simple HTML file
                echo "<html><body><h1>Images Instance</h1></body></html>" > /var/www/html/index.html
              EOF

  key_name = "my-key"  # Replace with your key pair name
}

# Launch Configuration for Videos instances
resource "aws_launch_configuration" "videos_lc" {
  name          = "videos-launch-configuration"
  image_id      = "ami-066784287e358dad1"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }

  security_groups = [aws_security_group.my_security_group.id]  # Add your security group IDs here

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting Videos Instance"
              # Add your custom setup scripts here
              sudo amazon-linux-extras install epel -y
              sudo yum install stress -y
              stress --cpu 1 --timeout 30000
              yum install -y htop
              EOF

  key_name = "my-key"  # Replace with your key pair name
}

# Auto Scaling Group for Images
resource "aws_autoscaling_group" "images_asg" {
  launch_configuration = aws_launch_configuration.images_lc.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  target_group_arns = [aws_lb_target_group.images_tg.arn]

  tag {
    key                 = "Name"
    value               = "Images Instance"
    propagate_at_launch = true
  }
}

# Auto Scaling Group for Videos
resource "aws_autoscaling_group" "videos_asg" {
  launch_configuration = aws_launch_configuration.videos_lc.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  target_group_arns = [aws_lb_target_group.videos_tg.arn]

  tag {
    key                 = "Name"
    value               = "Videos Instance"
    propagate_at_launch = true
  }
}
