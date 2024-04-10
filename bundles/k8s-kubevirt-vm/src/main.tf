locals {
  cluster_name    = split("/", var.kubernetes_cluster.data.infrastructure.arn)[1]
  node_group_name = "${local.cluster_name}-${var.kubernetes.node_group_name}"
}

data "aws_eks_node_group" "lookup" {
  cluster_name    = local.cluster_name
  node_group_name = local.node_group_name
}

resource "kubernetes_manifest" "vm" {
  manifest = {
    "apiVersion" = "kubevirt.io/v1"
    "kind"       = "VirtualMachine"
    "metadata" = {
      "name"      = var.md_metadata.name_prefix
      "namespace" = var.kubernetes.namespace
      "labels"    = var.md_metadata.default_tags
    }
    "spec" = {
      "running" = true
      "template" = {
        "spec" = {
          "domain" = {
            "devices" = {
              "disks" = [{
                "disk" = {
                  "bus" = "virtio"
                }
                "name" = "containerdisk"
                }, {
                "disk" = {
                  "bus" = "virtio"
                }
                "name" = "cloudinitdisk"
              }]
              "rng" = {}
            }
            "resources" = {
              "requests" = var.vm.resources
            }
          }
          "terminationGracePeriodSeconds" = 0
          # "accessCredentials" = [{
          #   "sshPublicKey" = {
          #     "source" = {
          #       "secret" = {
          #         "secretName" = "my-pub-key"
          #       }
          #     }
          #     "propagationMethod" = {
          #       "configDrive" = {}
          #     }
          #   }
          # }]
          "nodeSelector" = {
            "eks.amazonaws.com/nodegroup" = local.node_group_name
          }
          "tolerations" = [for taint in data.aws_eks_node_group.lookup.taints : {
            "key"      = taint.key
            "value"    = taint.value
            "effect"   = "NoSchedule"
            "operator" = "Equal"
          }]
          "volumes" = [{
            "containerDisk" = {
              "image" = var.vm.image
            }
            "name" = "containerdisk"
            }, {
            "cloudInitConfigDrive" = {
              "userData" = <<EOT
#cloud-config
password: fedora
chpasswd: { expire: False }
EOT
            }
            "name" = "cloudinitdisk"
          }]
        }
      }
    }
  }
}
