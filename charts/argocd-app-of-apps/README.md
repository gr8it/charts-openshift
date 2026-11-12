# ArgoCD App of Apps

Forked from <https://github.com/gnunn-gitops/argocd-app-of-app-chart>

A simple helm chart that can generate one or more Argo CD AppProject and Applications

AppProjects only render annotations when provided. Set `argocd.argoproj.io/sync-wave` in a project's `annotations` when ordering is needed.
