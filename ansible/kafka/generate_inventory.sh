#!/bin/bash
# ============================================
# Script : Génération automatique de l'inventaire Ansible
# Usage : bash generate_inventory.sh
# ============================================

set -e  # Arrêter en cas d'erreur

echo "🔍 Récupération des IPs depuis Terraform..."

# Aller dans le dossier Terraform
cd ../terraform

# Récupérer les outputs Terraform en JSON
OUTPUTS=$(terraform output -json)

# Extraire les IPs avec jq (outil JSON)
ZK_PUBLIC_IP=$(echo $OUTPUTS | jq -r '.zookeeper_public_ips.value[0]')
ZK_PRIVATE_IP=$(echo $OUTPUTS | jq -r '.zookeeper_private_ips.value[0]')
KAFKA_PUBLIC_IP=$(echo $OUTPUTS | jq -r '.kafka_broker_public_ips.value[0]')
KAFKA_PRIVATE_IP=$(echo $OUTPUTS | jq -r '.kafka_broker_private_ips.value[0]')

echo "✅ ZooKeeper Public IP  : $ZK_PUBLIC_IP"
echo "✅ ZooKeeper Private IP : $ZK_PRIVATE_IP"
echo "✅ Kafka Public IP      : $KAFKA_PUBLIC_IP"
echo "✅ Kafka Private IP     : $KAFKA_PRIVATE_IP"

# Revenir au dossier Ansible
cd ../ansible

# Générer le fichier inventory.ini
cat > inventory.ini <<EOF
# ============================================
# Inventaire généré automatiquement
# Généré le : $(date)
# ============================================

[zookeeper]
zk1 ansible_host=$ZK_PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/kafka-key.pem

[kafka]
broker1 ansible_host=$KAFKA_PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/kafka-key.pem

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

# Variables d'IPs privées (utilisées dans les playbooks)
zookeeper_private_ip=$ZK_PRIVATE_IP
kafka_private_ip=$KAFKA_PRIVATE_IP
EOF

echo ""
echo "✅ Fichier inventory.ini généré avec succès !"
echo ""
echo "📋 Contenu :"
cat inventory.ini

echo ""
echo "🚀 Vous pouvez maintenant lancer :"
echo "   ansible-playbook -i inventory.ini install_zookeeper.yml"
echo "   ansible-playbook -i inventory.ini install_kafka.yml"