variable "external_network_name" {
  type        = string
  default     = "external"
  description = "Nom du réseau public/externe pour les FIP et la passerelle du routeur."
}

variable "key_pair_name" {
  type        = string
  description = "Nom de la clé SSH pré-existante dans OpenStack pour accéder aux instances."
}

variable "flavor_bastion" {
  type    = string
  default = "m1.nano"
}

variable "flavor_compute" {
  type    = string
  default = "m1.medium"
}

variable "flavor_visu" {
  type    = string
  default = "m1.large"
}

variable "image_ubuntu" {
  type        = string
  default     = "Ubuntu 22.04"
  description = "Nom ou ID de l'image GLANCE à utiliser."
}
