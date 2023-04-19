locals {
  dlc_role_policy = file("./files/role-policy.json")
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlc-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "dlc-policy" {
  name = "dlc-role-policy"

  role = aws_iam_role.dlm_lifecycle_role.id
  policy = local.dlc_role_policy
}

// Data lifecycle management policy
resource "aws_dlm_lifecycle_policy" "example" {
  description        = "Creates snapshots with tags"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "EBS snapshots"

      create_rule {
        interval      = var.snap_rule.interval
        interval_unit = "HOURS"
        times         = var.snap_rule.times
      }

      retain_rule {
        count = var.retention
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = var.target_tags
  }
}
