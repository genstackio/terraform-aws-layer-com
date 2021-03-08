locals {
  identities = {
    main   = module.ses-regional-identity
  }
  smtp_user_infos = (null != var.smtp_user_name) ? {name = module.ses-smtp-user[0].name, arn = module.ses-smtp-user[0].arn, password = module.ses-smtp-user[0].password, login = module.ses-smtp-user[0].login} : null
}