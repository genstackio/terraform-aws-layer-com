locals {
  identities = {
    main   = merge(module.ses-regional-identity, {shared = false})
    shared = merge(module.ses-regional-identity-shared, {shared = true})
  }
}