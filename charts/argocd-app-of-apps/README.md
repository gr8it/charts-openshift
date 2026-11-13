# ArgoCD App of Apps

Forked from <https://github.com/gnunn-gitops/argocd-app-of-app-chart>

A simple helm chart that can generate one or more Argo CD AppProject and Applications

AppProjects only render annotations when provided. Set `argocd.argoproj.io/sync-wave` in a project's `annotations` when ordering is needed.

## Notes

We do not use sync waves to order the App of Apps for the following reasons:

- The modest reduction in API server and etcd load does not outweigh the extra Helm chart maintenance, operational overhead, and risk of deadlocks caused by dependencies between waves.
- Argo CD does not proceed to a later wave while resources in an earlier wave remain out of sync or unhealthy. An incomplete wave can therefore block all subsequent waves.

Sync waves may still be useful within an individual Application when appropriate for a specific use case.
