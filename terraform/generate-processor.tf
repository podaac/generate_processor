# Job Definition
resource "aws_batch_job_definition" "generate_batch_jd_processor" {
  name                  = "${var.prefix}-processor"
  type                  = "container"
  container_properties  = <<CONTAINER_PROPERTIES
  {
    "image": "${data.aws_ecr_repository.processor.repository_url}:latest",
    "jobRoleArn": "${data.aws_iam_role.batch_job_role.arn}",
    "environment": [
        {
            "name": "AWS_DEFAULT_REGION",
            "value": "us-west-2"
        }
    ],
    "logConfiguration": {
        "logDriver" : "awslogs",
        "options": {
            "awslogs-group" : "${data.aws_cloudwatch_log_group.cw_log_group.name}"
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
            "fileSystemId": "${data.aws_efs_file_system.aws_efs_generate.file_system_id}",
            "rootDirectory": "/processor"
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
    timeout {
    attempt_duration_seconds = 86400
  }
}