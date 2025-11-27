# Ingress configuration

Helm chart to apply following configuration for Ingress functionality:  

- base ingress controller settings: specify replicas and specific logging settings
- certificate: application wildcart certificate
- IPaddressPool: metallb IPadressPool for metallb service
- l2Advertisement: metallb L2Advertisement for specific IPaddressPool
- service: metallb service if IPaddressPool is specified