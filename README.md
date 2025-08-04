# Openshift helm charts repository

For best practices / contributing rules see [CONTRIBUTING.md](.github/CONTRIBUTING.md)

## Requirements

- Helm
- [Helm push plugin](https://github.com/chartmuseum/helm-push)
- Access to repository and Token

### List of helm chart packages provided

- bootstrap components
  - [ACM Operator](charts/acm-operator/)
  - [ACM Instance](charts/acm-instance/)
  - [GitOps Bootstrap](charts/gitops-bootstrap/)
  - [ArgoCD App of Apps](charts/argocd-app-of-apps/)
- library components
  - [ACM Configuration policy](charts/acm-configurationpolicy/)
  - [ACM Policy](charts/acm-policy/)
  - [ACM Operator policy](charts/acm-operatorpolicy/)
  - [Operators Installer](charts/operators-installer/)
- components
  - [Remove kubeadmin](charts/remove-kubeadmin/)

## Build a new/updated helm chart package

> [!TIP]  
> Don't forget to update helm chart version in Chart.yaml! Otherwise the helm Chart won't be build

Run:

```bash
make -C scripts/ build
```

### Cleanup of old packaged charts

During the build process, previously packaged Helm charts are retained in the [packaged-charts](./packaged_charts/) folder and remain referenced in the [index](index.yaml) file. This behavior is intentional, as it ensures that older chart versions remain accessible for compatibility and historical purposes.

To remove specific older chart versions or decommission charts entirely, delete the necessary files in [packaged-charts](./packaged_charts/) and [charts](./charts/) folders respectively and rebuild the index.

> [!IMPORTANT]  
> This will rebuild the complete helm repository index removing any unlinked references and fixing any potential issues with the file. This also has an unintended consequence of updating the `created` timestamp of all the remaining charts in the repository.

```bash
make -C scripts/ reindex
```

### Publish to Github (raw)

Everything required has been created on filesystem (index.yaml + packaged_charts/*.tgz), just push your changes to the main branch (via pull request)

### Publish to a helm repository (Gitlab, Harbor, Artifactory)

To publish the all (local) charts to a remote helm repository such as Gitlab, Harbor, Artifactory, .. be sure to export environment variables for repo URL, user and password:

```bash
export REPO_URL="https://github.com/gr8it/charts-openshift/"
export REPO_USERNAME="chartpusher"
export REPO_TOKEN="asd1e41123h12ey8haodasd"
```

and run:

```bash
make -C scripts/ publish
```

## Usage

### Github repo

Refers to the Git repo as a helm repository:

```bash
helm repo add gr8it https://raw.githubusercontent.com/gr8it/charts-openshift/main/
helm search repo gr8it -l
```

or replace main branch, with feature branch of your choice

> [!NOTE]  
> to get the URL, navigate to this repo on github.com, select README.md file, right click raw icon and select Copy link address (or similar) and remove the README.md part.

### Helm chart from remote location

Usage of **[Github repo](#github-repo) method is preferred** to this, as it leaves more space for repo reorganization without the need to change code. Refer to Helm chart package using url, e.g.:

```txt
helm template ad https://github.com/gr8it/charts/raw/main/active-directory-auth-provider-1.0.0.tgz
```

or replace main branch, with feature branch of your choice

> [!NOTE]  
> to get the URL, navigate to this repo on github.com, select particular chart .tgz stored in packaged_charts/ directory, right click raw icon and select Copy link address (or similar)

## TODO

- publish charts to OCI repo (ghcr.io)
