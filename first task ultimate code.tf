#the provider
provider "aws" {
    region = "us-east-2"
}

#Creating the  virtual network(VPC)
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MY_VPC"
    }
}

#Creating subnet
resource "aws_subnet" "my_app-subnet" {
    tags = {
        Name = "APP_Subnet"
    }
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    depends_on= [aws_vpc.my_vpc]

}

# configuring the route table
resource "aws_route_table" "my_route-table" {
    tags = {
        Name = "MY_Route_table"

    }
     vpc_id = aws_vpc.my_vpc.id
}

#Associating subnet with routing table
resource "aws_route_table_association" "App_Route_Association" {
  subnet_id      = aws_subnet.my_app-subnet.id
  route_table_id = aws_route_table.my_route-table.id
}


#Configuring the internet gateway for internet connection
resource "aws_internet_gateway" "my_IG" {
    tags = {
        Name = "MY_IGW"
    }
     vpc_id = aws_vpc.my_vpc.id
     depends_on = [aws_vpc.my_vpc]
}

#Adding default route in routing table to point to Internet Gateway
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.my_route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_IG.id
}

#Creating the  security group
resource "aws_security_group" "App_SG" {
    name = "App_SG"
    description = "Allow Web inbound traffic"
    vpc_id = aws_vpc.my_vpc.id
    ingress  {
        protocol = "tcp"
        from_port = 80
        to_port  = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress  {
        protocol = "tcp"
        from_port = 22
        to_port  = 22
        cidr_blocks = ["18.188.177.205/32"]
    }

    egress  {
        protocol = "-1"
        from_port = 0
        to_port  = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
#Creating the  private key which can be used to login to the webserver
resource "tls_private_key" "Web-Key" {
  algorithm = "RSA"
}

#Save public key  from the generated key
resource "aws_key_pair" "App-Instance-Key" {
  key_name   = "Web-key"
  public_key = tls_private_key.Web-Key.public_key_openssh
}

#Save the key to your local system
resource "local_file" "Web-Key" {
    content     = tls_private_key.Web-Key.private_key_pem
    filename = "Web-Key.pem"
}
#Create  webserver instance
resource "aws_instance" "Web" {
    ami = "ami-0d718c3d715cec4a7"
    instance_type = "t3.micro"
    root_block_device {
        volume_size = 10
    }
    tags = {
        Name = "WebServer1"
    }
    count =1
    subnet_id = aws_subnet.my_app-subnet.id
    key_name = "Web-key"
    security_groups = [aws_security_group.App_SG.id]

    provisioner "remote-exec" {
    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = tls_private_key.Web-Key.private_key_pem
        host = aws_instance.Web[0].public_ip
    }
    inline = [
       "sudo amazon-linux-extras install nginx1 -y",      # data scripts to install nginx, git and php
       "sudo yum install git -y",
       "sudo yum install php -y",
       "sudo systemctl restart nginx",
       "sudo systemctl enable nginx",
       "sudo rm -rf /usr/share/nginx/html/*",
       "sudo git clone https://github.com/sreehari93/ec2automation.git",   # cloning  files from github repo
       "sudo cp -r ec2automation/html5up/* /usr/share/nginx/html",   # copying  files to default data folder 
    ]
  }

}
