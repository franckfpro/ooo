# Récupération des infos du réseau externe existant
data "openstack_images_image_v2" "ubuntu" {
  name        = var.image_ubuntu
  most_recent = true
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# 1. Réseau privé et Subnet
resource "openstack_networking_network_v2" "internal" {
  name           = "internal-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal_subnet" {
  name            = "internal-subnet"
  network_id      = openstack_networking_network_v2.internal.id
  cidr            = "10.0.1.0/24"
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

# 2. Routeur pour le flux sortant (NAT)
resource "openstack_networking_router_v2" "router" {
  name                = "main-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.internal_subnet.id
}

# 3. Groupes de sécurité (Security Groups)

# Bastion : Autorise le SSH depuis l'extérieur
resource "openstack_compute_secgroup_v2" "bastion" {
  name        = "secgroup-bastion"
  description = "Autorise SSH entrant depuis Internet"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# Réseau Interne : Autorise le SSH uniquement depuis le Bastion, et le trafic interne entre les VMs
resource "openstack_compute_secgroup_v2" "internal_vms" {
  name        = "secgroup-internal"
  description = "Secgroup pour les machines privees"

  # SSH uniquement depuis le Bastion (via son IP privée ou son SecGroup si supporté)
  # Par sécurité/simplicité ici, on autorise le SSH venant du subnet interne
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = openstack_networking_subnet_v2.internal_subnet.cidr
  }

  # Exemple pour la machine de visualisation (ex: port 80/443 ou 3000) accessible depuis le réseau interne
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = openstack_networking_subnet_v2.internal_subnet.cidr
  }
}
