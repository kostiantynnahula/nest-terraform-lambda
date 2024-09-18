resource "aws_lambda_layer_version" "node_modules_layer" {
  layer_name          = "node_modules_layer"
  filename            = "./node_modules_layer.zip"
  compatible_runtimes = ["nodejs20.x"]
  source_code_hash    = filebase64sha256("./node_modules_layer.zip")
}


resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.app.execution_arn}/*/*"
}

resource "aws_lambda_function" "app" {
  filename         = data.archive_file.app_zip.output_path
  source_code_hash = data.archive_file.app_zip.output_base64sha256
  function_name    = "app"
  handler          = "dist/serverless.handler"
  runtime          = "nodejs20.x"
  memory_size      = 1024
  role             = aws_iam_role.lambda_exec.arn
  timeout          = 30
  # зададим перенные окружения, указав доступ к базе
  environment {
    variables = {
      NODE_ENV = "production"
    }
  }

  layers = [aws_lambda_layer_version.node_modules_layer.arn]
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/lambda/${aws_lambda_function.app.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
