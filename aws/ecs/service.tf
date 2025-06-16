terraform {
  backend "s3" {
    bucket         = "state-bucket-4-terra" # Your bucket name
    key            = "global/ecsservice/terraform.tfstate"     # Path to store state
    region         = "us-east-2"                       # Your region
    encrypt        = true
    dynamodb_table = "terraform-state-locks"           # Your DynamoDB table
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" # Change to your preferred region
}

# resource "aws_ecs_cluster" "foo" {
#   name = "white-hart"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }



# resource "aws_ecs_task_definition" "service" {
#   family = "service"
#   container_definitions = jsonencode([
#     {
#       name      = "first"
#       image     = "service-first"
#       cpu       = 10
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#     }
#   ])

#   volume {
#     name      = "service-storage"
#     host_path = "/ecs/service-storage"
#   }

# }

resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  execution_role_arn = "arn:aws:iam::751017186421:role/ecsTaskExecutionRole" #aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = <<TASK_DEFINITION
[
  {
    "cpu": 512,
    "memory": 1024,
    "essential": true,
    "image": "amazon/amazon-ecs-sample",
    "name": "nginx",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]
TASK_DEFINITION
}

# "image": "751017186421.dkr.ecr.us-east-2.amazonaws.com/sriniecs:1.27.2",

# resource "aws_ecs_service" "nginx" {
#   name            = "nginx"
#   cluster         = "arn:aws:ecs:us-east-2:751017186421:cluster/srini-ecr-service" # aws_ecs_cluster.foo.id
#   task_definition = aws_ecs_task_definition.service.arn #aws_ecs_task_definition.mongo.arn
#   launch_type     = "FARGATE"
#   desired_count   = 1
#   network_configuration {
#     subnets = [
#       "subnet-02875222072524e0a"
#     ]
#     security_groups = [
#       "sg-0d651c686d560ce78",
#     ]
#     assign_public_ip = false
#   }
# }
#   iam_role        = "arn:aws:iam::751017186421:role/ecsTaskExecutionRole" #aws_iam_role.foo.arn
#   depends_on      = [aws_iam_role_policy.foo]


#   load_balancer {
#     target_group_arn = aws_lb_target_group.srini.arn
#     container_name   = "nginx"
#     container_port   = 8080
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }

    # ,
    # "logConfiguration": {
    #     "logDriver": "awslogs",
    #     "options": {
    #         "awslogs-group": "/ecs/terratest",
    #         "mode": "non-blocking",
    #         "awslogs-create-group": "true",
    #         "max-buffer-size": "25m",
    #         "awslogs-region": "us-east-2",
    #         "awslogs-stream-prefix": "ecs"
    #     },
    #     "secretOptions": []
    # },
    # "systemControls": []

