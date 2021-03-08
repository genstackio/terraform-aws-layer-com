locals {
  identities = {
    main   = module.ses-regional-identity
    shared = module.ses-regional-identity-shared
  }
}