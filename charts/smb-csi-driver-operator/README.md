# smb-csi-driver operator

## Troubleshooting

### Blocked Operator upgrade

When operator upgrade is blocked on error due to not approved older Installplan :

``` bash
InstallPlan to update to [smb-csi-driver-operator.v4.17.0-202503121206] is available for approval but approval for [smb-csi-driver-operator.v4.17.0-202503121206] is required
```

Solution is to identify older Installplan version and remove it:

``` bash
# oc get installplan -A | grep smb-csi-driver-operator.v4.17.0-202503121206
openshift-cluster-csi-drivers              install-wts8t   smb-csi-driver-operator.v4.17.0-202503121206      Manual      false
# oc delete installplan install-wts8t -n openshift-cluster-csi-drivers
installplan.operators.coreos.com "install-wts8t" deleted
```