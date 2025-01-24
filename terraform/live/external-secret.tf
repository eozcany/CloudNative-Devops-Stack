#################################################
# External Secrets
#################################################
resource "helm_release" "external_secrets" {
  depends_on = [ module.eks ]
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.9"
  create_namespace = true

  values = [
    file("${path.module}/Values/external-secrets.yaml")
  ]
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.k8s_irsa["external-secrets"].role_arn
  }

  wait              = true
  timeout           = 300
  dependency_update = true
  reuse_values      = true
  lint              = true
  force_update      = true
  recreate_pods     = true
  atomic            = true
  cleanup_on_fail   = true
}

resource "kubectl_manifest" "cluster_secret_store" {
  depends_on = [
    helm_release.external_secrets,
  ]

  yaml_body = templatefile("${path.module}/templates/cluster_secret_store.yaml.tpl", {
    eks_cluster_id       = module.eks[0].cluster_name
    region               = var.region
    service_account_name = jsondecode(helm_release.external_secrets.metadata[0].values).serviceAccount.name
    namespace            = helm_release.external_secrets.namespace
  })
}