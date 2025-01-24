#################################################
# Cluster Autoscaler
#################################################
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.34.0"
  create_namespace = true

  values = [
    file("${path.module}/Values/cluster-autoscaler.yaml")
  ]

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.k8s_irsa["cluster-autoscaler"].role_arn
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