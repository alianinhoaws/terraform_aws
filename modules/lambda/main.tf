
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name = "lambda-invoke-policy"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LambdaPolicy",
        "Effect": "Allow",
        "Action": [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}


resource "aws_lambda_function" "terraform-lambda-node" {
  filename      = "../modules/lambda/exports.js.zip"
  function_name = "lambda_terraform2"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.handler"
  source_code_hash = filebase64sha256("../modules/lambda/exports.js.zip")

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  #source_code_hash = filebase64sha256("lambda_file.zip")

  runtime = "nodejs12.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform-lambda-node.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.labmda_terraform.arn
}

resource "aws_lb_target_group" "labmda_terraform" {
  name     = "lambda-terraform"
//  port     = 443
//  protocol = "HTTPS"
//  vpc_id   = var.vpc
  target_type = "lambda"
}


resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.labmda_terraform.arn
  target_id        = aws_lambda_function.terraform-lambda-node.arn
  depends_on       = [aws_lambda_permission.with_lb]
}
