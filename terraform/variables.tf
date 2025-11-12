# ============================================
# Variables pour le cluster Kafka
# ============================================

# Région AWS où déployer l'infrastructure
variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"  # Ireland
}

# Type d'instance pour les brokers Kafka
# t3.small = 1 CPU, 2 GB RAM, bon rapport prix/performance
variable "instance_type_broker" {
  description = "Type d'instance EC2 pour les brokers Kafka"
  type        = string
  default     = "t3.small"
}

# Type d'instance pour ZooKeeper
# t3.micro = 1 CPU, 1 GB RAM, moins puissant car ZK est léger
variable "instance_type_zk" {
  description = "Type d'instance EC2 pour ZooKeeper"
  type        = string
  default     = "t3.micro"
}

# Nombre de brokers Kafka à créer
# Minimum 3 en production, on en met 5 par défaut
variable "broker_count" {
  description = "Nombre de brokers Kafka"
  type        = number
  default     = 5
  
  validation {
    condition     = var.broker_count >= 3
    error_message = "Minimum 3 brokers requis pour la résilience."
  }
}

# Nombre d'instances ZooKeeper
# Toujours 3 pour un quorum stable
variable "zk_count" {
  description = "Nombre d'instances ZooKeeper"
  type        = number
  default     = 3
  
  validation {
    condition     = var.zk_count == 3
    error_message = "ZooKeeper doit avoir exactement 3 instances pour le quorum."
  }
}

# Taille du disque pour les brokers Kafka (en GB)
# 30 GB suffisant pour commencer, peut être augmenté
variable "ebs_volume_size" {
  description = "Taille du volume EBS pour stockage Kafka (en GB)"
  type        = number
  default     = 30
}

# Version de Kafka à installer
variable "kafka_version" {
  description = "Version de Kafka"
  type        = string
  default     = "3.6.0"
}

# Environnement (pour tags et identifiant)
variable "environment" {
  description = "Environnement (dev, staging, production)"
  type        = string
  default     = "production"
}

# Tag commun pour identifier toutes les ressources
variable "project_name" {
  description = "Nom du projet pour les tags"
  type        = string
  default     = "kafka-cluster"
}

# Votre IP pour accès SSH (IMPORTANT : à remplir !)
# Par défaut : 0.0.0.0/0 (ouvert au monde, NON sécurisé)
variable "allowed_ssh_cidr" {
  description = "CIDR autorisé pour SSH (ex: 203.0.113.0/32 pour votre IP)"
  type        = string
  default     = "0.0.0.0/0"  # ⚠️ À remplacer par votre IP en production
}