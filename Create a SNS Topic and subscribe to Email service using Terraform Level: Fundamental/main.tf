provider "aws" {

    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}
  #4. In the above code, you are defining the provider as aws.

  #5. Next, we want to tell Terraform to create a SNS topic named as whiz-topic.
#6. Paste the below content into the main.tf file after the provider.

resource "aws_sns_topic" "sns_topic" {
  name = "whiz-topic"
}

 #  7. Finally, to complete the main.tf file, let's add another set of code after sns topic creation where you will create a SNS subscription
 #          .  1.  topic_arn - This property allows to associate the subscription with the topic arn.

  #            2.  protocol - This property is used to tell which protocol we would use to confirm the subscription

   #           3. endpoint - In this lab , we will be using endpoint as email. Therefore, we have used a variable declared in the variables.tf file. While applying terraform ,terraform will ask the email id. 

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol= "email"
  endpoint= var.sns_subscription_email
  
}
   #8. Save the file by pressing Ctrl + S. 
