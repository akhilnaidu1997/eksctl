resource "aws_instance" "k8s" {
  ami           = local.ami_id
  instance_type = "t2.micro"
  user_data = file("workstattion.sh")
  iam_instance_profile = aws_iam_instance_profile.eks_role_profile.name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = false
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = self.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/akhilnaidu1997/eksctl.git",
      "cd eksctl",
      "eksctl create cluster --config-file=eks.yaml"
    ]
    on_failure = continue
  }

  tags = {
    Name = "k8s"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "eks-role"
  }
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "eks_role_profile" {
  name = "terraform-eks-profile"
  role = aws_iam_role.eks_role.name
}
