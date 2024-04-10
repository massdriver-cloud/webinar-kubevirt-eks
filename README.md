# KubeVirt in EKS Webinar

This repo contains the material to follow along with the KubeVirt in EKS webinar hosted by Massdriver. This webinar loosely follows the tutorial written by KubeVirt [here](https://kubevirt.io/2023/KubeVirt-on-autoscaling-nodes.html).


### Bundles

Bundles are stored in the [bundles](./bundles) directory. You can run `mass bundle publish` with the [Massdriver CLI](https://github.com/massdriver-cloud/mass) to publish and deploy from Massdriver.

### Manifests

Raw manifests are stored in the [manifests](./manifests) directory. You can run `kubectl apply -f <file>` to deploy into an EKS cluster.