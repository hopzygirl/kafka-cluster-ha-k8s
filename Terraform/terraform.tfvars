# ============================================
# Valeurs concrètes pour votre déploiement
# ============================================

# Région AWS - choisissez la plus proche de vos utilisateurs
aws_region = "eu-west-1"

# Nombre de brokers Kafka
# Commencez avec 5, vous pouvez augmenter plus tard
broker_count = 5

# Nombre de ZooKeeper (ne pas changer)
zk_count = 3

# Taille du disque pour Kafka (30 GB pour commencer)
ebs_volume_size = 30

# Version Kafka (stable et recommandée)
kafka_version = "3.6.0"

# Environnement
environment = "production"

# Nom du projet (visible dans les tags AWS)
project_name = "kafka-cluster"

# ⚠️ IMPORTANT : Remplacez par votre adresse IP publique !
# Trouvez votre IP : https://www.whatismyipaddress.com/
# Exemple : allowed_ssh_cidr = "203.0.113.45/32"
allowed_ssh_cidr = "0.0.0.0/0"
