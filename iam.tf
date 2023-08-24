resource "aws_iam_role" "taskrole" {
  name = "${var.prefix}-taskrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-task-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      // todo
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          Resource = [
            "arn:aws:logs:*:*:*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "executionrole" {
  name = "${var.prefix}-executionrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-execution-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          Resource = [
            "arn:aws:logs:*:*:*"
          ]
        }
      ]
    })
  }
}