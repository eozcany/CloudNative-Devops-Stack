#################################################
# Metrics Server
#################################################
resource "helm_release" "metrics_server" {
  depends_on = [ module.eks ]
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.11.0"

  values = [
    file("${path.module}/Values/metrics-server.yaml")
  ]


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
