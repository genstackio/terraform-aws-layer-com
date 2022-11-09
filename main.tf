module "ses-global" {
  source  = "genstackio/ses/aws//modules/global"
  version = "0.3.4"
  domain  = var.dns
  zone    = var.zone
}
module "ses-global-domains" {
  for_each = { for k,v in var.domains: k => v if null != lookup(v, "zone", null) }
  source   = "genstackio/ses/aws//modules/global"
  version  = "0.3.4"
  domain   = lookup(each.value, "dns", each.key)
  zone     = lookup(each.value, "zone", null)
}

module "ses-regional-identity" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.4"
  name            = "${var.env}-${replace(var.dns, ".", "-")}"
  sources         = var.sources
  service_sources = var.service_sources
  domain          = var.dns
  emails          = var.identities
}
module "ses-regional-identity-domains" {
  for_each        = { for k,v in var.domains: k => v if true == lookup(v, "regional", true) }
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.4"
  name            = lookup(each.value, "name", "${var.env}-${replace(lookup(each.value, "dns", each.key), ".", "-")}")
  sources         = lookup(each.value, "sources", [])
  service_sources = lookup(each.value, "service_sources", [])
  domain          = lookup(each.value, "dns", each.key)
  emails          = lookup(each.value, "identities", {})
}
module "ses-regional-identity-shared" {
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.4"
  name            = "${var.env}-${replace(var.dns, ".", "-")}"
  sources         = var.sources
  service_sources = var.service_sources
  domain          = var.dns
  emails          = var.identities
  providers = {
    aws = aws.shared
  }
}
module "ses-regional-identity-shared-domains" {
  for_each        = { for k,v in var.domains: k => v if true == lookup(v, "shared", true) }
  source          = "genstackio/ses/aws//modules/regional-identity"
  version         = "0.3.4"
  name            = lookup(each.value, "name", "${var.env}-${replace(lookup(each.value, "dns", each.key), ".", "-")}")
  sources         = lookup(each.value, "sources", [])
  service_sources = lookup(each.value, "service_sources", [])
  domain          = lookup(each.value, "dns", each.key)
  emails          = lookup(each.value, "identities", {})
  providers = {
    aws = aws.shared
  }
}

module "ses-global-verification" {
  source          = "genstackio/ses/aws//modules/global-verification"
  version         = "0.3.4"
  domain          = var.dns
  zone            = var.zone
  identities      = local.identities
}
module "ses-global-verification-domains" {
  for_each   = { for k,v in var.domains: k => v if null != lookup(v, "zone", null) }
  source     = "genstackio/ses/aws//modules/global-verification"
  version    = "0.3.4"
  domain     = lookup(each.value, "dns", each.key)
  zone       = lookup(each.value, "zone", null)
  identities = local.identities_domains
}

module "ses-regional-verification" {
  source     = "genstackio/ses/aws//modules/regional-verification"
  version    = "0.3.4"
  id         = module.ses-regional-identity.id
  depends_on = [module.ses-global-verification]
}
module "ses-regional-verification-domains" {
  for_each   = { for k,v in var.domains: k => v if true == lookup(v, "regional", true) }
  source     = "genstackio/ses/aws//modules/regional-verification"
  version    = "0.3.4"
  id         = module.ses-regional-identity-domains[each.key].id
  depends_on = [module.ses-global-verification-domains]
}
module "ses-regional-verification-shared" {
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.3.4"
  id        = module.ses-regional-identity-shared.id
  providers = {
    aws = aws.shared
  }
  depends_on = [module.ses-global-verification]
}
module "ses-regional-verification-shared-domains" {
  for_each   = { for k,v in var.domains: k => v if true == lookup(v, "shared", true) }
  source    = "genstackio/ses/aws//modules/regional-verification"
  version   = "0.3.4"
  id        = module.ses-regional-identity-shared-domains[each.key].id
  providers = {
    aws = aws.shared
  }
  depends_on = [module.ses-global-verification-domains]
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
module "pinpoint-app-domains" {
  for_each  = { for k,v in var.domains: k => v if null != lookup(v, "pinpoint_channels", null) && true == lookup(v, "shared", true) }
  source    = "genstackio/pinpoint/aws"
  version   = "0.2.0"
  name      = lookup(each.value, "name", "${var.env}-${replace(lookup(each.value, "dns", each.key), ".", "-")}")
  email     = null != lookup(lookup(each.value, "pinpoint_channels", {email = null}), "email", null) ? {
      from = format("%s@%s", lookup(lookup(each.value, "identities", {}), lookup(lookup(lookup(each.value, "pinpoint_channels", {email = null}), "email", null), "identity", {}), ""), lookup(each.value, "dns", null)),
      identity = module.ses-regional-identity-shared-domains[each.key].arn
    } : null
  sms       = null != lookup(lookup(each.value, "pinpoint_channels", {sms = null}), "sms", null) ? {} : null
  providers = {
    aws = aws.shared
  }
}
