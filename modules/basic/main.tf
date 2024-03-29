module "ses-global" {
  source  = "genstackio/ses/aws//modules/global"
  version = "0.3.0"
  domain  = var.dns
  zone    = var.zone
}

module "ses-regional-identity" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.0"
  name            = "${var.env}-${replace(var.dns, ".", "-")}"
  sources         = var.sources
  service_sources = var.service_sources
  domain          = var.dns
  zone            = var.zone
  emails          = var.identities
}
module "ses-global-verification" {
  source          = "genstackio/ses/aws//modules/global-verification"
  version         = "0.3.0"
  domain          = var.dns
  zone            = var.zone
  identities      = local.identities
}

module "ses-regional-verification" {
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.3.0"
  id        = module.ses-regional-identity.id
  depends_on = [module.ses-global-verification]
}

module "ses-smtp-user" {
  count   = null != var.smtp_user_name ? 1 : 0
  source  = "genstackio/ses/aws//modules/smtp-user"
  version = "0.3.0"
  name    = var.smtp_user_name
}