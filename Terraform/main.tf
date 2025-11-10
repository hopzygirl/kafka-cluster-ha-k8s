# ============================================
# Configuration du provider AWS
# ============================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuration AWS - utilise vos credentials
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================
# Récupérer l'AMI Ubuntu la plus récente
# ============================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu officiel)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================
# Clé SSH pour se connecter aux instances
# ============================================

# Génère une paire de clés SSH
resource "tls_private_key" "kafka_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Importe la clé publique dans AWS
resource "aws_key_pair" "kafka_deployer" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.kafka_key.public_key_openssh
}

# Sauvegarde la clé privée localement (pour SSH)
resource "local_file" "private_key" {
  content         = tls_private_key.kafka_key.private_key_pem
  filename        = "${path.module}/kafka-key.pem"
  file_permission = "0400"  # Lecture seule pour le propriétaire
}

# ============================================
# VPC par défaut (pour simplifier)
# ============================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ============================================
# INSTANCES ZOOKEEPER (3 instances)
# ============================================

resource "aws_instance" "zookeeper" {
  count = var.zk_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_zk
  key_name      = aws_key_pair.kafka_deployer.key_name

  # Sécurité réseau
  vpc_security_group_ids = [aws_security_group.zookeeper.id]

  # Disque de base (8 GB suffit pour ZooKeeper)
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  # Tags pour identifier l'instance
  tags = {
    Name = "${var.project_name}-zookeeper-${count.index + 1}"
    Role = "zookeeper"
    ID   = count.index + 1
  }

  # Script d'initialisation minimal
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-11-jdk netcat
              echo "ZooKeeper ${count.index + 1} initialisé"
              EOF
}

# ============================================
# INSTANCES KAFKA BROKERS (5 instances)
# ============================================

resource "aws_instance" "kafka_broker" {
  count = var.broker_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_broker
  key_name      = aws_key_pair.kafka_deployer.key_name

  # Sécurité réseau
  vpc_security_group_ids = [aws_security_group.kafka.id]

  # Disque pour stocker les logs Kafka
  root_block_device {
    volume_size = var.ebs_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  # Tags pour identifier l'instance
  tags = {
    Name     = "${var.project_name}-broker-${count.index + 1}"
    Role     = "kafka"
    BrokerID = count.index + 1
  }

  # Script d'initialisation minimal
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-11-jdk wget
              echo "Kafka Broker ${count.index + 1} initialisé"
              EOF

  # Attendre que ZooKeeper soit créé d'abord
  depends_on = [aws_instance.zookeeper]
}

# ============================================
# OUTPUTS - Informations utiles après déploiement
# ============================================

output "zookeeper_public_ips" {
  description = "Adresses IP publiques des ZooKeeper"
  value       = aws_instance.zookeeper[*].public_ip
}

output "zookeeper_private_ips" {
  description = "Adresses IP privées des ZooKeeper (pour Kafka)"
  value       = aws_instance.zookeeper[*].private_ip
}

output "kafka_broker_public_ips" {
  description = "Adresses IP publiques des brokers Kafka"
  value       = aws_instance.kafka_broker[*].public_ip
}

output "kafka_broker_private_ips" {
  description = "Adresses IP privées des brokers Kafka"
  value       = aws_instance.kafka_broker[*].private_ip
}

output "ssh_connection_command" {
  description = "Commande pour se connecter en SSH"
  value       = "ssh -i kafka-key.pem ubuntu@<IP_PUBLIQUE>"
}

output "private_key_location" {
  description = "Emplacement de la clé SSH privée"
  value       = abspath("${path.module}/kafka-key.pem")
}