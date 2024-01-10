resource "aws_iam_role" "this" {
  name               = "${var.role_name}Role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json

  dynamic "inline_policy" {
    for_each = data.aws_iam_policy_document.access_policy
    content {
      name   = "${var.role_name}Policy"
      policy = inline_policy.value.json
    }
  }

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.aws_managed_policy_name) > 0 ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.managed_policy[0].arn
}

resource "aws_iam_instance_profile" "this" {
  count = var.with_instance_profile ? 1 : 0
  name  = "${var.role_name}Role"
  role  = aws_iam_role.this.name
  tags  = var.tags
}
