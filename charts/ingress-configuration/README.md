# Ingress configuration

Helm chart to apply following configuration for Ingress functionality:  

- base ingress controller settings: specify replicas and specific logging settings
- certificate: application wildcart certificate
- IPaddressPool: metallb IPadressPool for metallb service, for each spoke cluster there is specific IP
- l2Advertisement: metallb L2Advertisement for specific IPaddressPool, specific per spoke cluster
- service: metallb service