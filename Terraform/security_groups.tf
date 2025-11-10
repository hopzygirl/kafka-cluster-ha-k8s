# ============================================
# Security Groups - Règles réseau (Firewall)
# ============================================

# ============================================
# Security Group pour Kafka Brokers
# ============================================

resource "aws_security_group" "kafka" {
  name        = "${var.project_name}-kafka-sg"
  description = "Security group pour les brokers Kafka"
  vpc_id      = data.aws_vpc.default.id

  # --- RÈGLES ENTRANTES (INGRESS) ---

  # Port 9092 : Communication Kafka
  # Autorisé depuis les autres brokers et les clients
  ingress {
    description     = "Kafka client communication"
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    self            = true  # Les brokers peuvent se parler entre eux
    security_groups = []
    cidr_blocks     = ["10.0.0.0/8"]  # Réseau interne AWS
  }

  # Port 22 : SSH pour administration
  # ⚠️ IMPORTANT : Restreindre à votre IP en production
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Port 9999 : JMX pour monitoring (optionnel)
  ingress {
    description = "JMX monitoring"
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    self        = true
  }

  # --- RÈGLES SORTANTES (EGRESS) ---

  # Autoriser tout le trafic sortant
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Tous les protocoles
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-kafka-sg"
    Role = "kafka"
  }
}

# ============================================
# Security Group pour ZooKeeper
# ============================================

resource "aws_security_group" "zookeeper" {
  name        = "${var.project_name}-zookeeper-sg"
  description = "Security group pour le cluster ZooKeeper"
  vpc_id      = data.aws_vpc.default.id

  # --- RÈGLES ENTRANTES (INGRESS) ---

  # Port 2181 : Client ZooKeeper
  # Autorisé depuis les brokers Kafka uniquement
  ingress {
    description     = "ZooKeeper client port"
    from_port       = 2181
    to_port         = 2181
    protocol        = "tcp"
    security_groups = [aws_security_group.kafka.id]
  }

  # Port 2888 : Communication entre instances ZooKeeper
  ingress {
    description = "ZooKeeper peer communication"
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    self        = true  # Les ZK peuvent se parler entre eux
  }

  # Port 3888 : Élection du leader ZooKeeper
  ingress {
    description = "ZooKeeper leader election"
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    self        = true
  }

  # Port 22 : SSH pour administration
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # --- RÈGLES SORTANTES (EGRESS) ---

  # Autoriser tout le trafic sortant
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-zookeeper-sg"
    Role = "zookeeper"
  }
}

# ============================================
# OUTPUTS - Informations security groups
# ============================================

output "kafka_security_group_id" {
  description = "ID du security group Kafka"
  value       = aws_security_group.kafka.id
}

output "zookeeper_security_group_id" {
  description = "ID du security group ZooKeeper"
  value       = aws_security_group.zookeeper.id
}