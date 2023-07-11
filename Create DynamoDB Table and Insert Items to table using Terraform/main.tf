#Task 4: Create a DynamoDB Table and its components in main.tf file
 #   1. To create a main.tf file, expand the folder task_10098_dynamodb and click on the New File icon to add the file.

  #  2. Name the file as main.tf and press Enter to save it.

 #   3. Paste the below content into the main.tf file.

provider "aws" {

    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}
 #In the above code, you are defining the provider as aws.

 #Next, we want to tell Terraform to create a DynamoDB table named as whiz-table.

 #Paste the below content into the main.tf file after the provider.

resource "aws_dynamodb_table" "dynamodb_table" {
  name = "whiz-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "RollNo."
   attribute {
    name = "RollNo."
    type = "N"
  }

}
#In the above code , we are telling terraform to create a table with table name as whiz-table. The billing mode should be provisioned by default. 

#One read capacity unit describes the one strongly consistent read per second upto 1 KB in size.

#One write capacity unit describes the one strongly consistent write per second upto 1 KB in size.

#Hash_key represents the partition key of an item. It is composed of one attribute that acts as a primary key for the table.

#We have defined RollNo. as the primary attribute which will be an integer. Therefore we have declared the type as “N”.

#Task 5: Adding items to the DynamoDB Table
#To add items to the table , paste the following content in the main.tf.


resource "aws_dynamodb_table_item" "item1" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
{
  "RollNo.": {"N": "1"},
  "Name": {"S": "Anant"}
}
ITEM
}
#In the above code, we have used the resource type as aws_dynamodb_table_item and associated this item with the table name and the hash key. We have declared an item with RollNo. as 1 and Name as Anant.

#You can similarly add more items. Paste the following content to add two more items.

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
{
  "RollNo.": {"N": "2"},
  "Name": {"S": "Pavan"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item3" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
{
  "RollNo.": {"N": "3"},
  "Name": {"S": "Nikhil"}
}
ITEM
}
