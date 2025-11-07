#Région AWS où sera déployer l'infrastructure
variable "region" {
  description = "Région AWS"
  type = string
  default = "eu-west-1" #Ireland
}

#Définition de la variable access_key pour AWS
variable "access_key" {
  type = string
}

#Définition de la variable secret_key pour AWS
variable "secret_key" {
  type = string
}

#Définition de la variable pour la création du cluster kafka
variable "kafka" {
  type = list
  default = ["kafka1", "kafka2", "kafka3","kafka4","kafka5"]
}

#Définition de la variable pour la création de la grappe de serveurs zookeeper
variable "zookeeper" {
  type = list
  default = ["zoo1", "zoo2","zoo3"]
}
