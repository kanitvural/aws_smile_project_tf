
resource "aws_lambda_function" "this" {
  count = length(var.lambda_functions)

  function_name    = var.lambda_functions[count.index].function_name
  handler          = var.lambda_functions[count.index].handler
  runtime          = var.lambda_functions[count.index].runtime
  role             = var.lambda_role_arn
  filename         = var.lambda_functions[count.index].source_zip
  source_code_hash = filebase64sha256(var.lambda_functions[count.index].source_zip)
  timeout          = var.lambda_functions[count.index].timeout


  tags = {
    Name = var.lambda_functions[count.index].function_name
  }
}













