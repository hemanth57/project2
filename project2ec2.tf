# Public subnet EC2 instance 1
resource "aws_instance" "project2-ec2-1" {
  ami             = "ami-067f3514568fd5760"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.project2-ec2-sg.id]
  subnet_id       = aws_subnet.project2-pub-sub-1.id
  key_name   = "jenkins"

  tags = {
    Name = "project2-ec2-1"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

# Public subnet  EC2 instance 2
resource "aws_instance" "project2-ec2-2" {
  ami             = "ami-067f3514568fd5760"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.project2-ec2-sg.id]
  subnet_id       = aws_subnet.project2-pub-sub-2.id
  key_name   = "jenkins"

  tags = {
    Name = "project2-ec2-2"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

#EIP

resource "aws_eip" "project2-ec2-1-eip" {
  vpc = true

  instance                  = aws_instance.project2-ec2-1.id
  depends_on                = [aws_internet_gateway.project2-igw]
}

resource "aws_eip" "project2-ec2-2-eip" {
  vpc = true

  instance                  = aws_instance.project2-ec2-2.id
  depends_on                = [aws_internet_gateway.project2-igw]
}
