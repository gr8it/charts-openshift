pkiIssuers:
  issuerName: APCCAi-Sp2
  pkiRoles:
    roles:
      apc:
        name: apc.socpoist.sk
        backend: pki
        defaultPkiPolicy: true
        settings:
          allowBareDomains: false
        allowedDomains:
          - "apc.socpoist.sk"
      hw:
        name: hw.apc.socpoist.sk
        backend: pki
        defaultPkiPolicy: true
        settings:
          allowSubdomains: false
          allowGlobDomains: true
          allowWildcardCertificates: false
        allowedDomains:
          - "*.hw.apc.socpoist.sk"
          - SR-BA-xAPC1-P1HM01i
          - SR-BA-xAPC1-P1HM02i
          - SR-BA-xAPC1-P1HW01i
          - SR-BA-xAPC1-P1HW02i
          - SR-BA-xAPC1-P1PW01i
          - SR-BA-xAPC1-P1PW02i
          - SR-BA-xAPC1-P1TW01i
          - SR-BA-xAPC1-P1DW01i
          - SR-BA-xAPC1-P2HM03i
          - SR-BA-xAPC1-P2HW03i
          - SR-BA-xAPC1-P2PW03i
          - SR-BA-xAPC1-P2PW04i
          - SR-BA-xAPC1-P2TW02i
          - SR-BA-xAPC1-P2TW03i
          - SR-BA-xAPC1-P2DW02i
          - SR-BA-xAPC1-P2DW03i
          - SR-BA-xAPC1XCA-P11
          - SR-BA-wAPC1-P1BKP1i
      cloud:
        name: cloud.socpoist.sk
        backend: pki
        defaultPkiPolicy: true
        allowedDomains:
          - cloud.socpoist.sk
          - svc
          - cluster.local

policies:
  customPolicies:
    pki-spoke-cluster-issuer:
      rules: |
        path "pki/sign/*" {
          capabilities = ["create", "update"]
        }
        path "pki/issuer/*" {
          capabilities = ["read"]
        }
        path "pki/roles/*" {
          capabilities = ["list"]
        }
        path "pki_int/sign/*" {
          capabilities = ["create", "update"]
        }
        path "pki/issue/apc.socpoist.sk" {
          capabilities = ["create", "update"]
        }


authMethods:
  approle:
    - name: approle
      enable: true      
  ldap:
    - name: ldap
      enable: true

releaseServiceOverride: ArgoCD

secretEngines:
  apc:
    type: kv-2
  apc-platform:
    type: kv-2
  pki:
    type: pki
