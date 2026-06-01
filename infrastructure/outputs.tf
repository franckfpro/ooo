output "bastion_public_ip" {
  value       = openstack_networking_floatingip_v2.bastion_fip.address
  description = "IP publique pour se connecter au Bastion en SSH."
}

output "calcul_private_ip" {
  value       = openstack_compute_instance_v2.calcul.network[0].fixed_ip_v4
  description = "IP privée de l'instance de calcul."
}

output "visualisation_private_ip" {
  value       = openstack_compute_instance_v2.visualisation.network[0].fixed_ip_v4
  description = "IP privée de l'instance de visualisation."
}
