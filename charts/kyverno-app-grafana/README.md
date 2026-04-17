# Kyverno app grafana

## Overview

This Helm chart installs Kyverno policy for Grafana custom resources.

The policy generates RBAC required for Grafana service accounts to read application logs.

## What it creates

The chart installs one `ClusterPolicy` which:

- matches `grafana.integreatly.org/*/Grafana` resources
- excludes Grafana resources from the `apc-observability` namespace
- generates a `ClusterRoleBinding` to `cluster-logging-application-view`

Generated names include the source namespace and Grafana resource name to avoid collisions.

## Usage

This chart is intended for user workload Grafana instances where generated logging RBAC should be created automatically by Kyverno.

The chart itself has minimal configuration.

## Values

Current configurable value in [values.yaml](./values.yaml):

- `releaseServiceOverride`

This value affects the `app.kubernetes.io/managed-by` label on rendered resources.
