# Default Network Policies

Implements APC best practice netpol:

- application / platform namespaces are isolated from each other
  - access between application / platform namespaces must be be explicitly enabled
- application / platform namespace pods can communicate within namespace <= created as a standard network policy via Kyverno
- application / platform namespaces are reachable from openshift operators, (user workload) and monitoring namespaces
- access from ingress is implemented as a standard network policy because ANP doesn't work with host network pods such as ingress controllers <= created via Kyverno
- egress is
  - implicitly allowed inside cluster, i.e. must be allowed as ingress on the receiving side
  - implicitly allowed within LAN except proxy, i.e. must be allowed on firewalls
    - access to Internet via proxy must be explicitly enabled using netpol with egress policy
- 
