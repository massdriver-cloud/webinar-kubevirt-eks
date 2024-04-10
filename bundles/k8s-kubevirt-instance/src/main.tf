locals {
  cluster_name    = split("/", var.kubernetes_cluster.data.infrastructure.arn)[1]
  node_group_name = "${local.cluster_name}-${var.kubernetes.node_group_name}"
}

data "aws_eks_node_group" "lookup" {
  cluster_name    = local.cluster_name
  node_group_name = local.node_group_name
}

resource "kubernetes_manifest" "kubevirt" {
  manifest = {
    "apiVersion" = "kubevirt.io/v1"
    "kind"       = "KubeVirt"
    "metadata" = {
      "name"      = var.md_metadata.name_prefix
      "namespace" = var.kubernetes.namespace
      labels      = var.md_metadata.default_tags
    }
    "spec" = {
      "certificateRotateStrategy" = {}
      "configuration" = {
        "developerConfiguration" = {
          "featureGates" = []
        }
      }
      "customizeComponents"    = {}
      "imagePullPolicy"        = "IfNotPresent"
      "workloadUpdateStrategy" = {}
      "infra" = {
        "nodePlacement" = {
          "tolerations" = [{
            "key"      = "CriticalAddonsOnly"
            "operator" = "Exists"
          }]
        }
      }
      "workloads" = {
        "nodePlacement" = {
          "tolerations" = [ for taint in data.aws_eks_node_group.lookup.taints : {
            "key"      = taint.key
            "value"    = taint.value
            "effect"   = "NoSchedule"
            "operator" = "Equal"
          }]
          "nodeSelector" = {
            "eks.amazonaws.com/nodegroup" = local.node_group_name
          }
        }
      }
    }
  }
}
