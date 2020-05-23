resource "aws_api_gateway_rest_api" "api" {
  name = "${var.api_name}Api"
}

resource "aws_api_gateway_resource" "publish_resource" {
  path_part   = "publish"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "publish_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.publish_resource.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.publish_resource.id
  http_method             = aws_api_gateway_method.publish_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda_function.invoke_arn

  request_templates = {
    "application/json" = var.json_request_template
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.publish_method.http_method}${aws_api_gateway_resource.publish_resource.path}"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "response_400" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "response_500" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = "500"
}

resource "aws_api_gateway_method_response" "response_504" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = "504"
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = var.json_response_template
  }
}

resource "aws_api_gateway_integration_response" "integration_response_400" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = aws_api_gateway_method_response.response_400.status_code
  selection_pattern = "Bad Request.*"

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "status":"400",
  "message":"$inputRoot.errorMessage"
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "integration_response_500" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = aws_api_gateway_method_response.response_500.status_code
  selection_pattern = "Server Error.*"

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "status":"500",
  "message":"$inputRoot.errorMessage"
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "integration_response_timeout" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.publish_resource.id
  http_method = aws_api_gateway_method.publish_method.http_method
  status_code = aws_api_gateway_method_response.response_504.status_code
  selection_pattern = ".*Task timed out.*"

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "status":"504",
  "message":"$inputRoot.errorMessage"
}
EOF
  }
}