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
variable "notifications_topic_arn" {
  type    = string
  default = null
}