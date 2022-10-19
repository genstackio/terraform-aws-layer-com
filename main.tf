module "ses-global" {
  source  = "genstackio/ses/aws//modules/global"
  version = "0.3.2"
  domain  = var.dns
  zone    = var.zone
}

module "ses-regional-identity" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.2"
  name            = "${var.env}-${replace(var.dns, ".", "-")}"
  sources         = var.sources
  service_sources = var.service_sources
  domain          = var.dns
  zone            = var.zone
  emails          = var.identities
}
module "ses-regional-identity-shared" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.2"
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
  version         = "0.3.2"
  domain          = var.dns
  zone            = var.zone
  identities      = local.identities
}

module "ses-regional-verification" {
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.3.2"
  id        = module.ses-regional-identity.id
  depends_on = [module.ses-global-verification]
}
module "ses-regional-verification-shared" {
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.3.2"
  id        = module.ses-regional-identity-shared.id
  providers = {
    aws = aws.shared
  }
  depends_on = [module.ses-global-verification]
}

module "pinpoint-app" {
  source    = "genstackio/pinpoint/aws"
  version   = "0.2.0"
  name      = "${var.env}-${replace(var.dns, ".", "-")}"
  email     = null != var.pinpoint_channels.email ? {from = "${var.identities[var.pinpoint_channels.email.identity]}@${var.dns}", identity = module.ses-regional-identity-shared.arn} : null
  sms       = null != var.pinpoint_channels.sms ? {} : null
  providers = {
    aws = aws.shared
  }
}

module "notifications" {
  for_each = (null != var.notifications_topic_arn) ? {for k,v in local.flatten_identities: k => {identity = lookup(v, "name"), topic_arn = var.notifications_topic_arn, types = lookup(v, "types", ["Bounce", "Delivery", "Complaint"])}} : {}
  source    = "genstackio/ses/aws//modules/notifications"
  version   = "0.3.2"
  identity  = lookup(each.value, "identity")
  topic_arn = lookup(each.value, "topic_arn")
  types     = lookup(each.value, "types")
}

module "notifications-shared" {
  for_each = (null != var.notifications_shared_topic_arn) ? {for k,v in local.flatten_identities_shared: k => {identity = lookup(v, "name"), topic_arn = var.notifications_shared_topic_arn, types = lookup(v, "types", ["Bounce", "Delivery", "Complaint"])}} : {}
  source    = "genstackio/ses/aws//modules/notifications"
  version   = "0.3.2"
  identity  = lookup(each.value, "identity")
  topic_arn = lookup(each.value, "topic_arn")
  types     = lookup(each.value, "types")
  providers = {
    aws = aws.shared
  }
}