variable "region" {
  default = "us-east-1"
  type    = string
}

variable "cluster_id" {
  description = "The Kubernetes (EKS) cluster id this role applies to"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace this role applies to"
  type        = string
}

variable "cluster_oidc_provider" {
  description = "The Kubernetes cluster OpenId Connect provider."
  type        = string
  default     = null
}

variable "service_acount_name" {
  description = "The Kubernetes service account name to use"
  type        = string
  default     = null
}

variable "name" {
  description = "Short, unique name for the given role. Must follow https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-limits.html#reference_iam-limits-names. Maximum length allowed is name - (cluster_id + namespace + 2)"
  type        = string
}

variable "policies" {
  description = "A list of AWS policies to add to this role"

  type = list(object({
    name   = string
    policy = string
  }))
}