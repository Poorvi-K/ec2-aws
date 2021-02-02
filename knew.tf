provider "aws" {
  region = "us-east-2"
  access_key = "XXXXXXXXX"
  secret_key = "XXXXXXXXXXXXX"
}

# create vpc
resource "aws_vpc" "knew" {
  cidr_block = "10.0.0.0/16"

tags={
    Name="knew"
}
}


#create internetgateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.knew.id

  tags = {
    Name = "knew"
  }
}

#create custom Route table

resource "aws_route_table" "knew" {
  vpc_id = aws_vpc.knew.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "knew"
  }
}

#Create a subnet
resource "aws_subnet" "knew" {
  vpc_id     = aws_vpc.knew.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "knew"
  }
}

#subnet association to route table
resource "aws_route_table_association" "knew" {
  subnet_id      = aws_subnet.knew.id
  route_table_id = aws_route_table.knew.id
}

#security group
resource "aws_security_group" "allow_webtraffic" {
  name        = "allow_webtraffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.knew.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#create networkinterface
resource "aws_network_interface" "knew" {
  subnet_id       = aws_subnet.knew.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_webtraffic.id]


}

#create elastic ip
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.knew.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

output "aws_eip_public_ip" {
    value = aws_eip.one.public_ip
  
}

#create ubuntu server
resource "aws_instance" "knew" {
    ami="ami-0a91cd140a1fc148a"
    instance_type = "t2.micro"
    availability_zone = "us-east-2a"
    key_name = "XXXX"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.knew.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo you knew everything >/var/www/html/index.html'
              EOF
    tags={
        Name="knew-web-server"
    }          


}
