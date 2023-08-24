
resource "aws_security_group" "efs" {
  name   = "${var.prefix}-efs"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "main" {
  creation_token = "${var.prefix}-efs"
}

resource "aws_efs_mount_target" "mount" {
  for_each        = toset(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "access" {
  file_system_id = aws_efs_file_system.main.id
  root_directory {
    path = "/n8n"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }
  }
}