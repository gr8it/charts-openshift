# GitOps bootstrap

This helm chart bootstraps APC GitOps using ACM policies to all managed clusters (global clusterset) using ACM policy framework:

- operatorpolicy to install ArgoCD opererator on managed clusters
- configurationpolicy to copy Gitops repo credentials secret from hub to managed clusters
- configurationpolicy to create Gitops repo secret on managed clusters
- configurationpolicy to create network policies for argocd to communicate correctly
- configurationpolicy to create App of Apps ArgoCD application on managed clusters with disabled sync to allow override in case of a problem

## Manual steps

When auto sync is not enabled for the argocd-app-of-apps application (default), the synchronization must be enabled temporarily by manually running the following commands **in the GitOps namespace** (the value of `.Values.namespace`, default `apc-gitops`):

```bash
# temporarily enable auto sync
kubectl patch application argocd-app-of-apps -n <gitops-namespace> --type merge -p '{"spec":{"syncPolicy":{"automated":{"selfHeal": true}}}}'
# disable auto sync, after the sync started (can be checked in the application CR status)
kubectl patch application argocd-app-of-apps -n <gitops-namespace> --type merge -p '{"spec":{"syncPolicy":{"automated": null}}}'
```

## OperatorPolicies not working

Because of a bug in ACM <https://access.redhat.com/support/cases/#/case/04386303/discussion> / <https://issues.redhat.com/browse/ACM-30555>, operator policy controller is not enabled (= missing --enable-operator-policy=true flag) in ACM configuration controller addon until cluster installation is finished, i.e. ingress controller cluster operator reporting not being healthy. However we need OperatorPolicy to finish the installation = install MetalLB and configure it. Resulting in a chicken-and-egg problem.

The workaround until a permanent solution is available is to annotate the particular `managedclusteraddon` on the hub cluster:

```bash
kubectl annotate managedclusteraddon config-policy-controller -n <hosted-cluster-namespace> operator-policy-disabled=false
```
