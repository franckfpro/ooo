# --- INSTANCE BASTION ---
resource "openstack_compute_instance_v2" "bastion" {
  name            = "bastion"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_name     = var.flavor_bastion
  key_pair        = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.bastion.name]

  network {
    uuid = openstack_networking_network_v2.internal.id
  }
}

# Allocation et association de l'IP flottante (FIP) au Bastion
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  pool = data.openstack_networking_network_v2.external.name
}

resource "openstack_compute_floatingip_associate_v2" "bastion_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.bastion_fip.address
  instance_id = openstack_compute_instance_v2.bastion.id
}


# --- INSTANCE CALCUL ---
resource "openstack_compute_instance_v2" "calcul" {
  name            = "instance-calcul"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_name     = var.flavor_compute
  key_pair        = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.internal_vms.name]

  network {
    uuid = openstack_networking_network_v2.internal.id
  }

  # Bonne pratique : s'assurer que le routeur est prêt pour que l'instance puisse faire ses updates (cloud-init)
  depends_on = [openstack_networking_router_interface_v2.router_interface]
}


# --- INSTANCE VISUALISATION ---
resource "openstack_compute_instance_v2" "visualisation" {
  name            = "instance-visualisation"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_name     = var.flavor_visu
  key_pair        = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.internal_vms.name]

  network {
    uuid = openstack_networking_network_v2.internal.id
  }

  depends_on = [openstack_networking_router_interface_v2.router_interface]
}
