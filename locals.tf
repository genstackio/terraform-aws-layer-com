locals {
  identities = {
    main   = merge(module.ses-regional-identity, {shared = false})
    shared = merge(module.ses-regional-identity-shared, {shared = true})
  }
  flatten_identities = merge(
    {main_domain = { arn = module.ses-regional-identity.arn, shared = false }},
    {for k,v in module.ses-regional-identity.email_identities: "main_email_${k}" => { arn = lookup(v, "arn"), shared = false}},
  )
  flatten_identities_shared = merge(
    {shared_domain = { arn = module.ses-regional-identity-shared.arn, shared = true }},
    {for k,v in module.ses-regional-identity-shared.email_identities: "shared_email_${k}" => { arn = lookup(v, "arn"), shared = true}},
  )
}