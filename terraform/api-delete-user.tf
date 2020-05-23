module "delete_user" {
  source = "./modules/lambda-api"

  api_name = "DeleteUser"
  http_method = "POST"

  json_request_template = <<EOF
#set($inputRoot = $input.path('$'))
{
  "userId" : "$input.path('userId')"
}
EOF

}

resource "aws_iam_role_policy_attachment" "delete_user_sqs_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role = module.delete_user.lambda_execution_role_name
}

resource "aws_iam_role_policy_attachment" "delete_user_dynamodb_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role = module.delete_user.lambda_execution_role_name
}