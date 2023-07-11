provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}			
#In the above code, you are defining the provider as aws.

#Next, we want to tell Terraform to create a Security Group within AWS EC2, and populate it with rules to allow traffic on specific ports. In our case, we are allowing the tcp port 80 (HTTP).

#We also want to make sure the instance can connect outbound on any port, so we’re including an egress section below as well.

#Paste the below content into the main.tf file after the provider.
############ Creating Security Group for EC2 & ELB ############

resource "aws_security_group" "web-server" {
    name        = "web-server"
    description = "Allow incoming HTTP Connections"
    ingress {
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
}			
#Let's add another set of code after security group creation where you will create 2 EC2 instances.

#In the below code, we have defined the Amazon Linux 2 AMI. The AMI ID mentioned above is for the us-east-1 region.

#We have mentioned the instance type as t2.micro and instance count to be created as 2.

#We have mentioned the resource which SSH key to use (which is already present in your AWS EC2 console). The security group ID is automatically taken by using the variable which we have set during the creation process.

#We have added the user data to install the apache server and add a html page.

#We have provided tags for the EC2 instances.
 ################## Creating 2 EC2 Instances ##################

resource "aws_instance" "web-server" {

    ami             = "ami-01cc34ab2709337aa"
    instance_type   = "t2.micro"
    count           = 2
    key_name        = "whizlabs-key"
    security_groups = ["${aws_security_group.web-server.name}"]
    user_data = <<-EOF
       #!/bin/bash
       sudo su
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><h1> Welcome to Whizlabs. Happy Learning from $(hostname -f)...</p> </h1></html>" >> /var/www/html/index.html
        EOF
    tags = {
        Name = "instance-${count.index}"
    }
}			
#Let's add another set of code after EC2 Instances creation where you will define the data source to get the details of vpc_id and subnet_id’s.

#Since we will be using the default VPC for the creation of ELB, we need the vpc_id and subnet_id’s. So, we will be using aws_vpc data source to provide details about the default VPC.

#We will also use the data source aws_subnet to provide a set of subnet id’s for a vpc_id.
###################### Default VPC and Subnets ######################

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet" "subnet1" {
    vpc_id = data.aws_vpc.default.id
    availability_zone = "us-east-1a"
}

data "aws_subnet" "subnet2" {
    vpc_id = data.aws_vpc.default.id
    availability_zone = "us-east-1b"
}			
#Let's add another set of code after the data source of VPC. Here, we will be creating the Target group.

#In the below code, we have provided the health check details.

#We have provided the protocol as HTTP and port as 80.

#The target type is instance and the vpc_id of the default VPC is taken from the data source variable.
#################### Creating Target Group ####################

resource "aws_lb_target_group" "target-group" {
    health_check {
        interval            = 10
        path                = "/"
        protocol            = "HTTP"
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
    }
    name          = "whiz-tg"
    port          = 80
    protocol      = "HTTP"
    target_type   = "instance"
    vpc_id = data.aws_vpc.default.id
}			
#Let's add another set of code after creating the Target group. We will be creating the Application Load Balancer and Listener in the below code.

#In the code below, we have mentioned the ip_address_type as ipv4. We have specified the load balancer type as an application.

#The security group ID is automatically taken by using the variable which we have set during the creation process.

#The subnet_ids of the default VPC are taken from the data variable.

#We have mentioned the tags for the load balancer.

#For the Listener, we have provided the load balancer arn which will be taken once the load balancer is created.

#We have configured the protocol and port as HTTP and 80 respectively and forwarded the request to the created target group
############# Creating Application Load Balancer #############

resource "aws_lb" "application-lb" {
    name            = "whiz-alb"
    internal        = false
    ip_address_type     = "ipv4"
    load_balancer_type = "application"
    security_groups = [aws_security_group.web-server.id]
    subnets = [
                data.aws_subnet.subnet1.id,
                data.aws_subnet.subnet2.id
                ]
    tags = {
        Name = "whiz-alb"
    }
}
 
######################## Creating Listener ######################

resource "aws_lb_listener" "alb-listener" {
    load_balancer_arn          = aws_lb.application-lb.arn
    port                       = 80
    protocol                   = "HTTP"
    default_action {
        target_group_arn         = aws_lb_target_group.target-group.arn
        type                     = "forward"
    }
}			
#Now, we have created the required resources. We will complete the main.tf by attaching the target group to the Application load balancer. 

#In the code below, we have specified the target group arn and the target_id, i.e the id’s of the created EC2 Instances.

################ Attaching Target group to ALB ################

resource "aws_lb_target_group_attachment" "ec2_attach" {
    count = length(aws_instance.web-server)
    target_group_arn = aws_lb_target_group.target-group.arn
    target_id        = aws_instance.web-server[count.index].id
}			
#Save the file by pressing Ctrl + S.
