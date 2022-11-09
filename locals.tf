locals {
  identities = {
    main   = merge(module.ses-regional-identity, {shared = false})
    shared = merge(module.ses-regional-identity-shared, {shared = true})
  }
  identities_domains = { for k,v in var.domains: k => {
    main   = merge(module.ses-regional-identity-domains[k], {shared = false})
    shared = merge(module.ses-regional-identity-shared-domains[k], {shared = true})
  } }
  flatten_identities = merge(
    {main_domain = { arn = module.ses-regional-identity.arn, name = module.ses-regional-identity.domain, shared = false }},
    {for k,v in module.ses-regional-identity.email_identities: "main_email_${k}" => { arn = lookup(v, "arn"), name = lookup(v, "email"), shared = false}},
  )
  flatten_identities_domains = { for kk, vv in var.domains: kk => merge(
    {main_domain = { arn = module.ses-regional-identity-domains[kk].arn, name = module.ses-regional-identity-domains[kk].domain, shared = false }},
    {for k,v in module.ses-regional-identity-domains[kk].email_identities: "main_email_${k}" => { arn = lookup(v, "arn"), name = lookup(v, "email"), shared = false}},
  ) }
  flatten_identities_shared = merge(
    {shared_domain = { arn = module.ses-regional-identity-shared.arn, name = module.ses-regional-identity-shared.domain, shared = true }},
    {for k,v in module.ses-regional-identity-shared.email_identities: "shared_email_${k}" => { arn = lookup(v, "arn"), name = lookup(v, "email"), shared = true}},
  )
  flatten_identities_shared_domains = { for kk, vv in var.domains: kk => merge(
    {shared_domain = { arn = module.ses-regional-identity-shared-domains[kk].arn, name = module.ses-regional-identity-shared-domains[kk].domain, shared = true }},
    {for k,v in module.ses-regional-identity-shared-domains[kk].email_identities: "shared_email_${k}" => { arn = lookup(v, "arn"), name = lookup(v, "email"), shared = true}},
  ) }
}