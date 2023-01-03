# ECR
resource "aws_ecr_repository" "processor" {
  name = "${var.prefix}-processor"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "generate_cw_log_group_processor" {
  name              = "/aws/batch/job/${var.prefix}-processor/"
  retention_in_days = 120
}

# Job Definition
resource "aws_batch_job_definition" "generate_batch_jd_processor" {
  name                  = "${var.prefix}-processor"
  type                  = "container"
  container_properties  = <<CONTAINER_PROPERTIES
  {
    "image": "${aws_ecr_repository.processor.repository_url}:latest",
    "logConfiguration": {
        "logDriver" : "awslogs",
        "options": {
            "awslogs-group" : "${aws_cloudwatch_log_group.generate_cw_log_group_processor.name}"
        }
    },
    "mountPoints": [
        {
            "sourceVolume": "processor",
            "containerPath": "/data",
            "readOnly": false
        }
    ],
    "resourceRequirements" : [
        { "type": "MEMORY", "value": "1024"},
        { "type": "VCPU", "value": "1024" }
    ],
    "volumes": [
        {
            "name": "processor",
            "efsVolumeConfiguration": {
            "fileSystemId": "${data.aws_efs_file_system.aws_efs_processor.file_system_id}",
            "rootDirectory": "/"
            }
        }
    ]
  }
  CONTAINER_PROPERTIES
  platform_capabilities = ["EC2"]
  propagate_tags        = true
  retry_strategy {
    attempts = 3
  }
}