
# Create a security group for the instances
resource "aws_security_group" "my_security_group" {
  name        = "my-instance-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.my_vpc.id

  # Allow inbound HTTP traffic from anywhere
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH traffic from a specific IP range (replace with your IP)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-instance-sg"
  }
}