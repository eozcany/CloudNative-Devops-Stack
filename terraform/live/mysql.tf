##############################################################################
# Helm Release: MySQL
##############################################################################

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "mysql_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "helm_release" "mysql" {
  depends_on = [ module.eks ]
  name             = "mysql"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "mysql"
  version          = "12.0.0"   # You see it in 'helm search repo' output
  namespace        = "mysql"
  create_namespace = true
  
  timeout          = 300
  reuse_values     = false
  force_update     = true
  lint             = true
  recreate_pods    = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true

  values           = [ file("${path.module}/Values/mysql.yaml") ]
  set {
    name  = "auth.rootPassword"
    value = random_password.mysql_root_password.result
  }

  set {
    name  = "auth.password"
    value = random_password.mysql_user_password.result
  }
  set {
    name  = "auth.database"
    value = var.reversed_ip_db
  }

  set {
    name  = "auth.username"
    value = var.reversed_ip_user
  }
}