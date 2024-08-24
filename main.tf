# main.tf

provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# Create an RDS instance
resource "aws_db_instance" "my_database" {
  identifier        = "cbioportal-db" # Replace with your desired DB instance identifier
  instance_class    = "db.t3.micro"  # Choose the instance type based on your requirements
  allocated_storage = 20             # Storage size in GB
  engine             = "mysql"       # Database engine (mysql, postgres, etc.)
  engine_version     = "8.0"         # Specify the version of the database engine
  username           = "admin"       # Master username
  password           = "root1234"    # Master password
  db_name            = "cbioportal"  # Initial database name
  parameter_group_name = "default.mysql8.0" # Default parameter group

  # Optional settings
  backup_retention_period = 7       # Retention period for backups
  skip_final_snapshot       = true  # Skip snapshot creation during deletion
  multi_az                  = false  # Set to true for multi-AZ deployments
  publicly_accessible       = true   # Set to false for private deployments

  tags = {
    Name = "My RDS Instance"
  }
}

# Create an RDS security group to control access
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"

  ingress {
    from_port   = 3306    # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

# Attach security group to RDS instance
resource "aws_db_instance" "my_database" {
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
}

# Optionally, create an IAM role and policy for running Python scripts
resource "aws_iam_role" "python_script_role" {
  name = "python_script_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "python_script_policy" {
  name = "python_script_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "python_script_role_policy_attachment" {
  role       = aws_iam_role.python_script_role.name
  policy_arn = aws_iam_policy.python_script_policy.arn
}
