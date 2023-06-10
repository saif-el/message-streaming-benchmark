resource "aws_default_vpc" "vpc" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.azs.names[0]
}

resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.azs.names[1]
}

resource "aws_default_subnet" "subnet_az3" {
  availability_zone = data.aws_availability_zones.azs.names[2]
}

resource "aws_default_security_group" "sg" {
  vpc_id = aws_default_vpc.vpc.id

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
      from_port   = 0
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
