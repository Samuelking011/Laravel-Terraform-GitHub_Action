#iam_roles.tf

#policy document granting permission to assume the role using temporary security credentials.
data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

#IAM role
resource "aws_iam_role" "ecs_tasks_execution_role" {
    name                        = "${var.app_name}-ecs-task-execution-role"
    description                 = "${var.app_name} ECS tasks execution role"
    assume_role_policy          = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json

    tags = {
        Name            = "${var.app_name}"
        Environment     = "${var.app_env}"
    }
}

#Store the ARN value of AmazonEC2ContainerServiceforEC2Role into the custom policy.
data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#attach custom policy created above to IAM role.
resource "aws_iam_role_policy_attachment" "ecs_access_policy_attachment" {
    role       = aws_iam_role.ecs_tasks_execution_role.name
    policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
}

#custom policy for allowing S3 access from Laravel application running in Fargate.
data "aws_iam_policy_document" "ecs_php_s3_policy_document" {
    statement {
        actions = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject"
        ]

        resources = [
        "${aws_s3_bucket.ecs_s3.arn}",
        "${aws_s3_bucket.ecs_s3.arn}/*",
        ]
    }
}

#S3 access policy.
resource "aws_iam_policy" "ecs_php_s3_policy" {
    name        = "${var.app_name}-ecs-s3-policy"
    description = "PHP access to S3"
    policy      = data.aws_iam_policy_document.ecs_php_s3_policy_document.json
}

#Attach the policy for S3 access to the previously created IAM role.
resource "aws_iam_role_policy_attachment" "web_ec2_s3_policy_attachment" {
    role       = aws_iam_role.ecs_tasks_execution_role.name
    policy_arn = aws_iam_policy.ecs_php_s3_policy.arn
}