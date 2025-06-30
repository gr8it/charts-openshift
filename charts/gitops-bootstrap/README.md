# GitOps bootstrap

This helm chart bootstraps APC GitOps using ACM policies to all managed clusters (global clusterset) using ACM policy framework:

- operatorpolicy to install ArgoCD opererator on managed clusters
- configurationpolicy to copy Gitops repo credentials secret from hub to managed clusters
- configurationpolicy to create Gitops repo secret on managed clusters
- configurationpolicy to create App of Apps ArgoCD application on managed clusters
