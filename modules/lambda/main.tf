
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
  handler       = var.entrypoint
  source_code_hash = filebase64sha256("${var.file_path}")

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
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.labmda_terraform.arn
  target_id        = aws_lambda_function.terraform-lambda-node.arn
  depends_on       = [aws_lambda_permission.with_lb]
}
