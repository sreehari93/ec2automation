# ec2automation
this project is on internship process from stackgenie

10:00 - read tasks in detail 
 plans : 1.understand deploying  static websites using nginx
         2.try a demo in vm(centos 8) 
         3.create a github public repository 
reffered tutorials: edureka turorial on deploying a web application using nginx  ( https://www.youtube.com/watch?v=1ndlRiaYiWQ ), serving a static content https://www.youtube.com/watch?v=jGHyaBpEn0g&t=154s, Web Server Project -- 01 Setting up Nginx (https://www.youtube.com/watch?v=ZyQRqa8I6bU&t=349s )
configured nginx in vm
downloaded a static content fron html5up 
loaded the static content successfully 
created a public repository in github 

learned how to automate ec2 creation using terraform with tutorials : https://www.youtube.com/watch?v=rR8YNxHnNjw  , https://www.youtube.com/watch?v=6gKhCGYuHu4 , 
https://www.youtube.com/watch?v=LZtSZexSYG4

configured terraform in aws instance and automated instance creation (t3.micro) 

steps followed :
1. configuration of terraform in control node (parent system )
  1.wget: " the link address of terraform  linux platform 64-bit"  #  download  zip file 
  2.unzip the downloaded file 
  3. moved to /bin
  4. directory named terraform_project was made 
  5. cd terraform_project 
  6. downloaded accesskeys and secret key from security credentials 
  7. configured  file named main.tf
  8. code used 
  9.  provider "aws" {
 access_key = "xxxxxxxxxxxx"
 secret_key = "xxxxxxxxxxxxxxxxx"
 region = "us-east-2"
}
resource "aws_instance" "sample" {
ami = "ami-0d718c3d715cec4a7"
instance_type = "t3.micro"
}

initiated terraform  using terraform init 
validated using terraform validate 
all passed 
instance was created using  command  terraform apply 


got a vague idea on how to automate 

automation part 
 
using the main system,
create s3 bucket using terraform (https://www.youtube.com/watch?v=_M2eUQW_zVI&t=235s)
add static website content zip folder in it (reffered https://www.youtube.com/watch?v=3ahcgi8RqCM // have to sort for multiple files though  ) 

create t3.micro ec2 instance  using terraform  (add user-data scripts of launching website using nginx server) (https://www.youtube.com/watch?v=rR8YNxHnNjw&t=251s)
 
user-data scripts include :
nginx installing and configuration 
fetching zipped file from the s3 bucket 
unzipping and moving the static webcontent to the nignx data folder 
starting nginx 
check whether the website is launched successfully  

# best idea is to split terraform file to 3 parts 
1st part : provider details 
2nd part: creating s3 bucket and adding files into it 
3rd part : creating aws instance with user-data script 

no update today 
learned how to copy files from windows to aws instance  using scp  ( https://www.youtube.com/watch?v=qnn8iVcXJxw&t=1095s )  
learned how to copy multiple files to s3  from a linux machine( aws instance)  using terraform  {  https://linoxide.com/upload-files-to-s3-using-terraform/  , https://www.youtube.com/watch?v=5FBspkGMV_4&t=1041s }
tried to approach the concept of fetching files from s3 bucket  found some codes but was unaable to understand what each lines really do. another option found was using aws s3 cp command which lead to  aws cli concepts again was stuck on brainstorming what to do incase of automation . gave up todays whole effort . most of the codes  intention are clear but line by line understanding needs more time i guess.
no update today 
gone through  concepts: aws cli configuration in linux , implementing cli commands using terraform , reffered terraform cli documentation , configuring pc, security groups, gateway,block volumes etc (time spent : 9 hours ) 

concepts about vpc, subnets associating , cloud front , tried connecting instance configured automatically but instance failed to connect. observed that inbound rules where not set and was added to default security group as security groups was not configured .  time spent ( 4 hours)
wont be updating anything for two days as i will be out of town.



First task completed : code is given here 


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
time spent (6 hours )

the code i reffered was from https://github.com/vineets300/Webpage1.git

learned basic docker configurations in linux, dockerfiles and pulled nginx image 
reffered: (https://www.youtube.com/watch?v=cdqbPfGkUu4&t=603s, https://www.youtube.com/watch?v=pTFZFxd4hOI, https://www.youtube.com/watch?v=LQjaJINkQXY&t=257s )
time spent 8 hours 
containerised nginx using docker in the local machine and uploaded static website 
