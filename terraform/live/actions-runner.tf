##############################################################################
# Helm Release: cert-manager
##############################################################################
resource "helm_release" "cert_manager" {
  depends_on = [ module.eks ]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.16.3"
  namespace        = "cert-manager"
  create_namespace = true

  timeout          = 300
  reuse_values     = false
  force_update     = true
  lint             = true
  recreate_pods    = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true

  set {
    name  = "crds.enabled"
    value = true
  }

  set {
    name  = "prometheus.enabled"
    value = false
  }
}

##############################################################################
# Helm Release: actions-runner-controller
##############################################################################
resource "helm_release" "actions_runner_controller" {
  depends_on = [ module.eks, helm_release.cert_manager ]
  name             = "actions-runner"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart            = "actions-runner-controller"
  version          = "0.23.7"
  namespace        = "actions-runner"
  create_namespace = true
  
  timeout          = 300
  reuse_values     = false
  force_update     = true
  lint             = true
  recreate_pods    = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true

  values = [
    file("${path.module}/Values/actions-runner-controller.yaml")
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.k8s_irsa["actions-runner"].role_arn
  }
}

##############################################################################
# Runner Deployment
##############################################################################
resource "kubernetes_cluster_role" "runner_cluster_role" {
  metadata {
    name = "runner-cluster-role"
  }

  rule {
    api_groups = ["*"]        # Apply to all API groups
    resources  = ["*"]        # Apply to all resources
    verbs      = ["*"]        # Allow all verbs (actions)
  }
}

resource "kubernetes_cluster_role_binding" "runner_cluster_role_binding" {
  metadata {
    name = "runner-cluster-role-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "actions-runner" # Replace with your service account name
    namespace = helm_release.actions_runner_controller.namespace         # Namespace where the service account is located
  }

  role_ref {
    kind     = "ClusterRole"
    name     = kubernetes_cluster_role.runner_cluster_role.metadata[0].name # Reference the created ClusterRole
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubectl_manifest" "runner_deployment" {
  depends_on = [ helm_release.actions_runner_controller ]

  yaml_body = templatefile("${path.module}/Templates/runner_deployment.yaml.tpl", {
    name                 = "arc-runner"
    namespace            = helm_release.actions_runner_controller.namespace
    labels               = ["arc"]
    repository           = "eozcany/reversed-ip"
  })
}

