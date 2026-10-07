# infraenv

- DONE remove vault parametrization
- DONE make envName required in schema
- DONE move NTP to apc-global-overrides as .global.apc.services.ntp.servers
  - don't forget to add library-charts-unittests/apc-global-overrides-unit-tests
- DONE move sshAuthorizedKey to apc-global-overrides as .global.apc.sshAuthorizedKey
  - don't forget to add library-charts-unittests/apc-global-overrides-unit-tests
  - and make it plural sshAuthorizedKeys as it can contain several authorized keys, one per line
- DONE make nmStateConfigs required in schema
- DONE merge feature flags into values

# hcp

- DONE remove vault parametrization => use convention over configuration => see cluster-infraenv for implementation
- DONE add a default etcd.storageClassName = lvms-vg1
- DONE make clusterSet default to clusterName with trailing numbers removed, e.g. clusterName prod01 => clusterSet prod
- DONE hardcode networkType OVNKubernetes, don't make it configurable
- DONE rename nodePorts to services 
- DONE use apc-global-overrides.clusterRootDomain instead of baseDomain
- DONE use sshAuthorizedKeys from apc-global-overrides
- DONE use NTP from apc-global-overrides
- DONE merge feature flags into values
- DONE move imageProxy.registryHost and imageProxy.sources to apc-global-overrides as .global.apc.services.imageProxy.host and .global.apc.services.imageProxy.sources
  - don't forget to add library-charts-unittests/apc-global-overrides-unit-tests
- DONE remove imageProxy.caCert in favor of apc-global-overrides.caCertificatesBundle only
- DONE adIntegration
  - remove adIntegration.caCert in favor of apc-global-overrides.caCertificatesBundle only
  - move to apc-global-overrides as .global.apc.services.adIntegration 
    - create one helper returing the whole dictionary
    - keep defaults for attributes
- DONE do similar to the adIntegration
- DONE replace ExternalSecret kube-apiserver-cert with cert-manager certificate
  - use api.{{ $clusterName }}.{{ $baseDomain }}, and oauth.{{ $clusterName }}.{{ $baseDomain }} for FQDNs to request cert for
- DONE remove externalsecret sshkey-cluster-* in favor of a secret (it contains public keys only, which are by definition public)
- DONE make hostedcluster.spec.channel configurable with default set to eus-4.18
- DONE parametrize the kubeletconfig-worker = kubeletConfig should be configurable as a dictionary, and used as a whole

- DONE make all required values (e.g. clusterName) from the manifests required in the schema and mark in the README values list
- merge bindPassword secret name (from external secret) as ldap.attributes.bindPassword.name to the adIntegration / ldapIntegration dictionary, and move to an helper
- merge ca name (from relevant config map) as ldap.attributes.ca.name to the adIntegration / ldapIntegration dictionary, and move to an helper

- make the apc-global-overrides.sshAuthorizedKeys an list. Add a new helpers sshAuthorizedKeysBundle and require-sshAuthorizedKeysBundle, similar to caCertificatesBundle. Update documentation, unittest (at the library-charts-unittests/apc-global-overrides-unit-tests) and its usage

# apc-global-overrides

- NA add schema file
- DONE check unittests (apc-global-overrides-unit-tests)

# cluster config standalone

- add machineconfig ???

# conf repo TODO

- add new apc-global-overrides to conf-socpoist, conf-qa-sp
  - ntp, sshAuthorizedKeys, imageProxy.registryHost, imageProxy.sources

-----------

- skontrolovat vault linky
  - standardizovat nepriec chartami
- aktualizovat dokumentaciu (README)
  - hlavne external secret sources
- ma byt oauth .name, .ldap.attributes.url, a .ldap.attributes.bindDN povinne ???
