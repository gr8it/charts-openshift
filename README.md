# Openshift helm charts repository

For best practices / contributing rules see [CONTRIBUTING.md](.github/CONTRIBUTING.md)

## Requirements

- [helm cli >=3.8](https://github.com/helm/helm/releases)
- [git cli](https://git-scm.com)
- [yq v4 (mikefarah) ](https://github.com/mikefarah/yq/releases)
- Optional: Write access to registry (`write:packages` in case of ghcr.io)

### List of helm chart packages provided

- bootstrap components
  - [ACM Operator](charts/acm-operator/)
  - [ACM Instance](charts/acm-instance/)
  - [GitOps Bootstrap](charts/gitops-bootstrap/)
  - [ArgoCD App of Apps](charts/argocd-app-of-apps/)
  - [Crossplane Helm](charts/crossplane-helm/)
  - [Crossplane Vault Provider](charts/crossplane-vault-provider/)
  - [Crossplane Vault Provider Bootstrap](charts/crossplane-vault-provider-bootstrap/)
  - [Cert Manager Operator](charts/cert-manager-operator/)
  - [Cert Manager Config](charts/cert-manager-config/)
  - [External Secrets Operator](charts/external-secrets-operator/)
  - [External Secrets Config](charts/external-secrets-config/)
- library components
  - [APC Global Overrides](charts/apc-global-overrides/)
  - [ACM Configuration policy](charts/acm-configurationpolicy/)
  - [ACM Policy](charts/acm-policy/)
  - [ACM Operator policy](charts/acm-operatorpolicy/)
  - [Operators Installer](charts/operators-installer/)
- components
  - [Remove kubeadmin](charts/remove-kubeadmin/)
  - ...

## Build a new/updated helm chart package

> [!TIP]  
> Don't forget to update helm chart version in Chart.yaml! Otherwise the helm Chart will be skipped

Run:

```bash
make build
```

> [!NOTE]  
> Helm chart will be linted before packaging

### Helm chart lint

While linting can be launched manually, it is always included when building / packaging a chart.

```bash
make lint
```

For cases, where linting fails, a lint configuration can be supplied by creating `values.lint.yaml` file. This lint values file is used automatically, when it exists.

### Publish to Github (raw)

Everything required has been created on filesystem (index.yaml + packaged_charts/*.tgz), just push your changes to the main branch (via pull request)

### Publish to oci registry

To publish all local charts to a remote oci registry (such as ghcr, quay, ..), be sure to export environment variables for registry user and password.
The variable for registry url is optional and defaults to `ghcr.io/<git-remote-repo>`  (git-remote-repo is derived from the output of `git config --get remote.origin.url`).
Github note:

- GitHub Packages only supports authentication using a personal access token (classic). For more information, see [documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

```bash
export REGISTRY_USER="registry-user"
export REGISTRY_TOKEN="ghp_E6pjd ..... jweUO71"
export REGISTRY_URL="ghcr.io/gr8it/charts-openshift"
```

To push packaged chart as oci images to a registry, run:

```bash
CHARTFOLDER=<chart dir name> make publish
```

Where \<chart dir name\> is a directory name in the charts folder.

> [!WARNING]  
> Charts won't be pushed to destination if the same tag already exists! Either chart version must be increased, or the chart version deleted in the oci registry (usually using registry GUI)

### Cleanup of decommission charts

During the build process, previously packaged Helm charts are retained in the [packaged-charts](./packaged_charts/) folder and remain referenced in the [index](index.yaml) file. This behavior is intentional, as it ensures that older chart versions remain accessible for compatibility and historical purposes.

To remove specific older chart versions or decommission charts entirely, delete the necessary files in [packaged-charts](./packaged_charts/) and/or [charts](./charts/) folders respectively and run the `clean` target.

```bash
make clean
```

### Regenerate Index

If there's any problem with the index file, it is possible to regenerate it from scratch.

> [!IMPORTANT]  
> This will rebuild the helm repository index removing any unlinked references and fixing any potential issues with the file. This also has an unintended consequence of updating the `created` timestamp of all the remaining charts in the repository.

```bash
make reindex
```

## Usage

### Github repo

Refers to the Git repo as a helm repository:

```bash
helm repo add gr8it-openshift https://raw.githubusercontent.com/gr8it/charts-openshift/main/
helm search repo gr8it-openshift -l
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

- figure out a publishing process for the oci registry
