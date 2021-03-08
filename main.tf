module "ses-global" {
  source  = "genstackio/ses/aws//modules/global"
  version = "0.1.0"
  domain  = var.dns
  zone    = var.zone
}

module "ses-regional-identity" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.1.0"
  name            = "${var.env}-${replace(var.dns, ".", "-")}"
  sources         = var.sources
  service_sources = var.service_sources
  domain          = var.dns
  zone            = var.zone
  emails          = var.identities
  providers = {
    aws = aws
  }
}
module "ses-regional-identity-shared" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.1.0"
  name            = "${var.env}-${replace(var.dns, ".", "-")}"
  sources         = var.sources
  service_sources = var.service_sources
  domain          = var.dns
  zone            = var.zone
  emails          = var.identities
  providers = {
    aws = aws.shared
  }
}

module "ses-global-verification" {
  source          = "genstackio/ses/aws//modules/global-verification"
  version         = "0.1.0"
  domain          = var.dns
  zone            = var.zone
  identities      = local.identities
  providers = {
    aws = aws
  }
}

module "ses-regional-verification" {
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.1.0"
  id        = module.ses-regional-identity.id
  providers = {
    aws = aws
  }
  depends_on = [module.ses-global-verification]
}
module "ses-regional-verification-shared" {
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.1.0"
  id        = module.ses-regional-identity-shared.id
  providers = {
    aws = aws.shared
  }
  depends_on = [module.ses-global-verification]
}

module "pinpoint-app" {
  source    = "genstackio/pinpoint/aws"
  version   = "0.1.0"
  name      = "${var.env}-${replace(var.dns, ".", "-")}"
  email     = null != var.pinpoint_channels.email ? {from = "${var.identities[var.pinpoint_channels.email.identity]}@${var.dns}", identity = module.ses-regional-identity-shared.arn} : null
  providers = {
    aws = aws.shared
  }
}