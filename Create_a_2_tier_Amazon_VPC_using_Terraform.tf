Create a variables file
In this task, you will create variables files where you will declare all the global variables with a short description and a default value.

To create variables files, click on the File from the menu bar and choose New file

Press Ctrl + S to save the new file as variables.tf and click on the Save button after entering the file name.

Note: Don't change the location of the new file, keep it default, i.e. inside the task_10000_vpc folder.

Paste the below contents in variables.tf file:
variable "access_key" {
    description = "Access key to AWS console"
}
variable "secret_key" {
    description = "Secret key to AWS console"
}
variable "region" {
    description = "Region of AWS VPC"
}			
In the above content, you are declaring a variable called, access_key, secret_key, and region with a short description of all 3.
After pasting the above contents, save the file by pressing Ctrl + S.

Now create the terraform.tfvars file by selecting New file present under File in the menu bar.

Name the file by pressing Ctrl + S and enter terraform.tfvars

Paste the below content into terraform.tfvars file
region = "us-east-1"
access_key = "<YOUR AWS CONSOLE ACCESS ID>"
secret_key = "<YOUR AWS CONSOLE SECRET KEY>"
in the above code, you are defining the dynamic values of variables declared earlier.

Replace the values of access_key and secret_key by copying from the lab page.

After replacing the values of access_key and secret_key, save the file by pressing Ctrl + S.

Task 4: Create VPC and its components in main.tf file
In this task, you will create main.tf file where you will add details of the provider and resources.
To create main.tf file, click on the File from the menu bar and choose New file

Press Ctrl + S to save the new file as main.tf and click on the Save button after entering the file name.

Paste the below content into main.tf file.
provider "aws" {
     region     = var.region
     access_key = var.access_key
     secret_key = var.secret_key
}
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
}			
provider "aws" {
     region     = var.region
     access_key = var.access_key
     secret_key = var.secret_key
}
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
}			
In the above code, you are defining provider as aws and defining resource block using aws_vpc for creating an Amazon VPC having CIDR Block as 10.0.0.0/24.

Define Internet gateway, route table, and subnets in all availability zone. Add the below contents after aws_vpc block.

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "route" {
    route_table_id         = aws_vpc.vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gateway.id
}
data "aws_availability_zones" "available" {}

resource "aws_subnet" "main" {
   count                   = length(data.aws_availability_zones.available.names)
   vpc_id                  = aws_vpc.vpc.id
   cidr_block              = "10.0.${count.index}.0/24"
   map_public_ip_on_launch = true
   availability_zone       = element(data.aws_availability_zones.available.names, count.index)
}
In the above code, you are performing the following tasks:

Creating an Internet gateway and attaching it with the VPC.

Adding route as 0.0.0.0/0 and destination as an Internet gateway.

Checking all the availability zones.

Creating subnets in all availability zones.

Save the file by pressing Ctrl + S.
