data "aws_iam_policy_document" "neptune_kms" {
  statement {
    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = concat(
        ["arn:aws:iam::${local.account_id}:root"],
        [for user in data.aws_iam_user.admin : user.arn],
        [for role in data.aws_iam_role.admin : role.arn],
      )
    }
  }

  statement {
    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "logs.${local.aws_region}.amazonaws.com",
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${local.aws_region}:${local.account_id}:*",
      ]
    }
  }
}

data "aws_iam_policy_document" "neptune_s3" {
  statement {
    sid    = "HTTPSRequestsOnly"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.neptune.arn,
      "${aws_s3_bucket.neptune.arn}/*",
    ]

    principals {
      type = "*"
      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
      ]
    }
  }
}

data "aws_iam_policy_document" "vpce_s3" {
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "*",
    ]

    principals {
      type = "*"
      identifiers = [
        "*",
      ]
    }
  }
}

data "aws_iam_policy_document" "api_gateway" {
  statement {
    actions = [
      "execute-api:Invoke"
    ]

    resources = [
      "arn:aws:execute-api:${local.aws_region}:${local.account_id}:*/*",
    ]

    principals {
      type = "*"
      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpc"
      values = [
        var.vpc_id,
      ]
    }
  }
}

data "aws_iam_policy_document" "neptune_user" {
  count = var.create_iam_user ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      module.neptune_user[0].role_arn,
    ]
  }
}
