#################################################
# EKS Provisioning
#################################################
module "eks" {
  count   = local.create_eks ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33.1"

  cluster_name                             = "reversed-ip-eks"
  cluster_version                          = "1.30"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  kms_key_administrators = [
    "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
  ]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    general_compute_spot_a = {
      node_group_name = "general_compute_spot_a"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy            = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEKS_CNI_Policy                = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryPowerUser = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
      }
      create_launch_template = true
      launch_template_os     = "bottlerocket"
      public_ip              = false
      desired_size = 1
      max_size     = 3
      min_size     = 1
      ami_type      = "BOTTLEROCKET_x86_64"
      capacity_type = "SPOT"
      ebs_optimized = true
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_type = "gp2"
            volume_size = 40
          }
        }
      ]
      instance_types = [
        "t3a.medium", "t3.medium",
      ]
      subnet_ids = [module.vpc.private_subnets[0]]
      k8s_labels = {
        Environment = "dev"
        Capacity    = "2vCpu4Gib"
        WorkerType  = "SPOT"
      }
      tags = local.tags
    }
  }

  node_security_group_additional_rules = {
    node_to_node_ingress_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    node_to_node_egress_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
    egress_all = {
      description = "Allow all pod egress for outbound communication"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
}