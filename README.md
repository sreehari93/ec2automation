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


