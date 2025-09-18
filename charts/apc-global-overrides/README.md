# APC Global Overrides

APC Gitops uses global values to share parameters in the environment. These can be either used directly (.Values.global.apc...) or overriden by values local to a specific chart. While it is straightforward to override strings, it is harder to do so for lists, dictionaries, and booleans.

This chart aims to help with the logic of overriding the global values with the local ones, as the logic is shared between several charts.

The chart creates helper functions for all global values, where:

- a local override strips the .global.apc from global value, e.g. .Values.global.apc.cluster.name => local override is .Values.cluster.name
- the namespace for all helper function is apc-global-overrides
- the name of the helper function is camelCase of the value, e.g. .Values.cluster.name => apc-global-overrides.clusterName
- for most of the values a require helper function is available, which requires the particular value to be set, e.g. apc-global-overrides.require-clusterName
- for dictionary values a merge helper function is available, e.g. .Values.caCertificates => apc-global-overrides.merge-caCertificates. This function merges local and global dictionaries giving preference to the local value. This is different to the "normal" helper function, which uses local dictionary if defined, otherwise fallsback to the global dictionary.

## Usage

Define this chart as a dependency:

```yaml
dependencies:
  - name: global-apc-overrides
    version: "1.0.0"
    repository: https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/main/

```

Reference particular helper function in chart template:

```go
{{ include "global-apc-overrides.clusterName" .}}
```

Local overrides can be specified as:

```yaml
cluster:
  name: klaster1
```

> [!NOTE]  
> While it is usually required to specify the subchart name in values.yaml to forward values to a subchart, e.g.
>
> ```yaml
> global-apc-overrides:
>   cluster:
>     name: klaster1
> ```
>
> **This is not the case here**, because we're not using template rendering, but helper functions, where context is sent directly - via 2nd parameter, e.g. dot in the `{{ include "global-apc-overrides.clusterName" . }}`

See [APC Global Overrides Unit Tests chart](../../library-charts-unittests/apc-global-overrides-unit-tests/README.md) for usage.

## Unit tests

As this chart is a library chart, unit tests can't be implemented here => unit tests are implemented in [APC Global Overrides Unit Tests chart](../../library-charts-unittests/apc-global-overrides-unit-tests/README.md)
