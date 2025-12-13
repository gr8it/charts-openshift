# MetalLB configuration repository

This Helm Chart prepares MetalLB configuration for APC deployment with HCP in place. 

Following resources are deployed:  

- priority class, used for metallb instance
- metallb instance
- IP address pool:
  - on HUB cluster there are three adress pools each for specific spoke cluster and the address pool is targeting kube-apiserver service
- L2Advertisement:
  - three for each spoke kube-api server on HUB cluster
- Kyverno cluster policy which will update L2Advertisement if this one have no interface configured

For more details follow [official MetalLB documentation](https://metallb.io/).  

## TODO
- once HCP gitops deployemnt is ready, move IPAdressPool and L2advertisement to HCP deployment/configuration part