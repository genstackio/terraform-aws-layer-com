variable "env" {
  type = string
}
variable "dns" {
  type = string
}
variable "zone" {
  type = string
}
variable "identities" {
  type    = map(string)
  default = {}
}
variable "sources" {
  type    = list(string)
  default = []
}
variable "service_sources" {
  type    = list(string)
  default = []
}
variable "pinpoint_channels" {
  type = object({
    email = object({identity = string})
    sms   = optional(object({}))
  })
}
variable "domains" {
  type = map(object({
    dns               = string
    zone              = optional(string)
    identities        = map(string)
    sources           = optional(list(string))
    service_sources   = optional(list(string))
    pinpoint_channels = optional(object({
      email = optional(object({identity = string}))
      sms = optional(object({}))
    }))
  }))
  default = {}
}