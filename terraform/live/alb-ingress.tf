#################################################
# ALB Ingress Controller Configurations
#################################################
resource "helm_release" "alb_ingress" {
  depends_on = [ module.eks ]
  name       = "alb-ingress"
  namespace  = "alb-ingress"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.8"
  create_namespace = true

  values = [
    file("${path.module}/Values/alb-ingress.yaml")
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.k8s_irsa["alb-ingress"].role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks[0].cluster_name
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  wait              = true
  timeout           = 600
  dependency_update = true
  reuse_values      = true
  lint              = true
  force_update      = true
  recreate_pods     = true
  atomic            = true
  cleanup_on_fail   = true
}

resource "aws_security_group" "sg_alb_ingress" {
  name        = "alb-ingress-${module.eks[0].cluster_name}"
  description = "Allow Secure Traffic between ALB and Kubernetes Services"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound traffic
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound traffic
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      module.eks[0].node_security_group_id # Whitelist Kubernetes Private Subnets
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group_rule" "allow_all_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1" # -1 means all protocols
  source_security_group_id = resource.aws_security_group.sg_alb_ingress.id
  security_group_id        = module.eks[0].node_security_group_id
}

resource "kubernetes_namespace" "reversed_ip" {
  metadata {
    name = "reversed-ip"
  }
}

resource "kubernetes_ingress_v1" "reversed_ip" {
  metadata {
    name      = "reversed-ip"
    namespace = resource.kubernetes_namespace.reversed_ip.metadata[0].name

    annotations = {
      "alb.ingress.kubernetes.io/certificate-arn"    = module.acm.acm_certificate_arn
      "alb.ingress.kubernetes.io/subnets"            = join(", ", module.vpc.public_subnets)
      "alb.ingress.kubernetes.io/security-groups"    = aws_security_group.sg_alb_ingress.id
      "alb.ingress.kubernetes.io/load-balancer-name" = "reversed-ip"
      "alb.ingress.kubernetes.io/conditions.reversed-ip" = jsonencode([{
        field = "host-header"
        hostHeaderConfig = {
          values = ["reversed-ip.hyprime.io"]
        }
      }])
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      "alb.ingress.kubernetes.io/actions.reversed-ip" = jsonencode({
        Type = "forward"
        ForwardConfig = {
          TargetGroups = [{
            ServiceName = "reversed-ip"
            ServicePort = 80
          }]
        }
      })
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80,\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/ssl-policy"   = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/group.name"   = "reversed-ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "reversed-ip"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

