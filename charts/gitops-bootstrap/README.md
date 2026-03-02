# GitOps bootstrap

This helm chart bootstraps APC GitOps using ACM policies to all managed clusters (global clusterset) using ACM policy framework:

- operatorpolicy to install ArgoCD opererator on managed clusters
- configurationpolicy to copy Gitops repo credentials secret from hub to managed clusters
- configurationpolicy to create Gitops repo secret on managed clusters
- configurationpolicy to create network policies for argocd to communicate correctly
- configurationpolicy to create App of Apps ArgoCD application on managed clusters with disabled sync to allow override in case of a problem

## Manual steps

When auto sync is not enabled for the argocd-app-of-apps application (default), the synchronization must be enabled temporarily by manually running:

```bash
# temporarily enable auto sync
kubectl patch application argocd-app-of-apps -n apc-gitops --type merge -p '{"spec":{"syncPolicy":{"automated":{"selfHeal": true}}}}'
# disable auto sync, after the sync started (can be checked in the application CR status)
kubectl patch application argocd-app-of-apps -n apc-gitops --type merge -p '{"spec":{"syncPolicy":{"automated": null}}}'
```
