data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifiers
    }
  }
}

data "aws_iam_policy_document" "access_policy" {
  count = length(var.statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.statements

    content {
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

data "aws_iam_policy" "managed_policy" {
  count = length(var.aws_managed_policy_name) > 0 ? 1 : 0
  name  = var.aws_managed_policy_name
}
