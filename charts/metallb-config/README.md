# MetalLB configuration repository

This Helm Chart prepares MetalLB configuration for APC deployment with HCP in place. 

Following resources are deployed:  

- priority class, used for metallb instance
- metallb instance
- IP address pool:
  - there is one address pool for each spoke cluster
  - on HUB cluster there are three adress pools each for specific spoke cluster and the address pool is targeting kube-apiserver service
- L2Advertisement:
  - one for each spoke cluster
  - three for each spoke kube-api server on HUB cluster
- Service, created only on spoke clusters, service is targeting default ingresscontroller
- Kyverno cluster policy which will update L2Advertisement if this one have no interface configured
- namespace, main purpose is to set monitoring label on metallb namespace

For more details follow [official MetalLB documentation](https://metallb.io/).