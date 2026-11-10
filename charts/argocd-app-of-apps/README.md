# ArgoCD App of Apps

Forked from <https://github.com/gnunn-gitops/argocd-app-of-app-chart>

A simple helm chart that can generate one or more Argo CD AppProject and Applications

Generated AppProjects default to sync wave `-1`, so they are created before Applications that reference them. A project's `annotations` are preserved.
