locals {
  project_prefix = data.tfe_outputs.infra.values.project_prefix
  build_suffix = data.tfe_outputs.infra.values.build_suffix
  #59origin_bigip = try(data.tfe_outputs.bigip.values.bigip_public_vip, "")
  #59origin_nginx = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name, "")
  origin_bigip = try(data.tfe_outputs.bigip[0].values.bigip_public_vip, "")
  origin_nginx = try(data.tfe_outputs.nap[0].values.external_name, data.tfe_outputs.nic[0].values.external_name, "")
  origin_server = "${coalesce(local.origin_bigip, local.origin_nginx, var.serviceName)}"
  #59origin_port = try(data.tfe_outputs.nap.values.external_port, data.tfe_outputs.nic.values.external_port, "80")
  origin_port = try(data.tfe_outputs.nap[0].values.external_port, data.tfe_outputs.nic[0].values.external_port, "80")
  dns_origin_pool = local.origin_nginx != "" ? true : false 
}
