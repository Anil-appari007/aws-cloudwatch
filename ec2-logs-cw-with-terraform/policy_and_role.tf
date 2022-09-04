#######################
##  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy

#   policy creation
resource "aws_iam_policy" "logs-push-policy" {
  name        = "cw-policy-to-push-logs-to-ec2"
  path        = "/"
  description = "cw-policy-to-push-logs-to-ec2"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
})
}


##  Create role
resource "aws_iam_role" "ec2-cw-role" {
    name = "cw-ec2-logs-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

###########
resource "aws_iam_role_policy_attachment" "attach-cw-role" {
    role = aws_iam_role.ec2-cw-role.id
    policy_arn = aws_iam_policy.logs-push-policy.id
}


#############
resource "aws_iam_instance_profile" "profile" {
    name = "ec2-cw-profile"
    role = aws_iam_role.ec2-cw-role.id
}
