terraform {
  backend "azurerm" {}
}

data "terraform_remote_state" "shared" {
  backend = "azurerm"

  config {
    storage_account_name = "${var.k8sbook_prefix}${var.k8sbook_chap}tfstate"
    container_name       = "tfstate-shared"
    key                  = "terraform.tfstate"
  }
}

module "primary" {
  source = "../modules/cluster-blue-aad"

  prefix                              = "${var.k8sbook_prefix}"
  chap                                = "${var.k8sbook_chap}"
  cluster_type                        = "primary"
  resource_group_name                 = "${data.terraform_remote_state.shared.resource_group_name}"
  location                            = "${data.terraform_remote_state.shared.resource_group_location}"
  aad_tenant_id                       = "${var.k8sbook_aad_tenant_id}"
  aad_ext_tenant_id                   = "${var.k8sbook_aad_ext_tenant_id}"
  aad_client_app_id                   = "${var.k8sbook_aad_client_app_id}"
  aad_server_app_id                   = "${var.k8sbook_aad_server_app_id}"
  aad_server_app_secret               = "${var.k8sbook_aad_server_app_secret}"
  log_analytics_workspace_id          = "${data.terraform_remote_state.shared.log_analytics_workspace_id}"
  action_group_id_critical            = "${data.terraform_remote_state.shared.action_group_id_critical}"
  traffic_manager_profile_name        = "${data.terraform_remote_state.shared.traffic_manager_profile_name}"
  traffic_manager_endpoint_priority   = 100
  cosmosdb_account_name               = "${data.terraform_remote_state.shared.cosmosdb_account_name}"
  cosmosdb_account_primary_master_key = "${data.terraform_remote_state.shared.cosmosdb_account_primary_master_key}"
}

module "failover" {
  source = "../modules/cluster-blue-aad"

  prefix                              = "${var.k8sbook_prefix}"
  chap                                = "${var.k8sbook_chap}"
  cluster_type                        = "failover"
  resource_group_name                 = "${data.terraform_remote_state.shared.resource_group_name}"
  location                            = "${var.k8sbook_failover_location}"
  aad_tenant_id                       = "${var.k8sbook_aad_tenant_id}"
  aad_ext_tenant_id                   = "${var.k8sbook_aad_ext_tenant_id}"
  aad_client_app_id                   = "${var.k8sbook_aad_client_app_id}"
  aad_server_app_id                   = "${var.k8sbook_aad_server_app_id}"
  aad_server_app_secret               = "${var.k8sbook_aad_server_app_secret}"
  log_analytics_workspace_id          = "${data.terraform_remote_state.shared.log_analytics_workspace_id}"
  action_group_id_critical            = "${data.terraform_remote_state.shared.action_group_id_critical}"
  traffic_manager_profile_name        = "${data.terraform_remote_state.shared.traffic_manager_profile_name}"
  traffic_manager_endpoint_priority   = 500
  cosmosdb_account_name               = "${data.terraform_remote_state.shared.cosmosdb_account_name}"
  cosmosdb_account_primary_master_key = "${data.terraform_remote_state.shared.cosmosdb_account_primary_master_key}"
}
