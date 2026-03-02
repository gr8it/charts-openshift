# MetalLB App IP - Crossplane Custom Resource

This Helm chart provides Crossplane manifests for managing MetalLB IPAddressPool and L2Advertisement resources through a single unified custom resource definition.

## Overview

The `MetalLBAppIP` custom resource simplifies the creation and management of MetalLB configurations by combining IPAddressPool and L2Advertisement into a single, namespace-scoped resource.

### What Gets Created

When you create a `MetalLBAppIPClaim`, Crossplane will automatically create:
1. **IPAddressPool** - Defines the pool of IP addresses available for allocation
2. **L2Advertisement** - Advertises the IP addresses over Layer 2

## Custom Resource Definition (XRD)

**Group:** `metallb.crossplane.io`
**Kind:** `MetalLBAppIP`
**Claim Kind:** `MetalLBAppIPClaim`

### Spec Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `namespace` | string | ✓ | Kubernetes namespace where MetalLB resources will be created |
| `poolName` | string | ✓ | Name for the IPAddressPool resource |
| `addressRanges` | string[] | ✓ | List of IP ranges or CIDR blocks (e.g., `["10.0.0.0/24", "192.168.1.10-192.168.1.20"]`) |
| `autoAssign` | boolean | ✗ | Allow automatic assignment of addresses (default: true) |
| `advertisementName` | string | ✗ | Name for the L2Advertisement resource (defaults to auto-generated) |
| `interfaces` | string[] | ✗ | Network interfaces to advertise from (optional for L2Advertisement) |

## Status Fields

The status section exposes information about the created resources and discovery:

```yaml
status:
  existingAddresses:
    - 10.0.0.0/24
    - 10.1.0.0/24
  discoveredPoolCount: 2
  
  availableRanges:
    - 10.100.0.0/16
  excludedRangeCount: 2
  
  addressPool:
    name: <pool-name>
    ready: true
    conditions: <conditions-array>
  
  allocatedAddresses:
    - 10.100.0.0/16
  
  l2Advertisement:
    name: <advertisement-name>
    ready: true
    conditions: <conditions-array>
  
  observedGeneration: <generation>
```

## Pipeline Architecture

The composition uses a 4-step pipeline:

### Step 0: Discover Existing IPs (get-existing-ips)
- Queries all existing IPAddressPool resources from the cluster
- Extracts addresses from discovered pools
- Updates status with `existingAddresses` and `discoveredPoolCount`
- Prevents allocation conflicts by identifying already-used ranges

### Step 1: Read Configuration (read-config)
- Loads address ranges from configuration
- Filters out ranges already used by existing pools
- Selects first available range for allocation
- Updates status with `allocatedAddresses` and `availableRanges`

### Step 2: Create Resources (patch-and-transform)
- Creates IPAddressPool with allocated addresses
- Creates L2Advertisement linked to the pool
- Syncs resource status back to composite

### Step 3: Verify Readiness (ready)
- Checks IPAddressPool is Ready
- Checks L2Advertisement is Ready
- Marks composite as ready when both conditions met

## Usage Examples

### Basic Usage

Create an IP address pool in the `metallb-system` namespace:

```yaml
apiVersion: metallb.crossplane.io/v1alpha1
kind: MetalLBAppIPClaim
metadata:
  name: my-app-ip
  namespace: default
spec:
  namespace: metallb-system
  poolName: app-pool
  addressRanges:
    - 10.0.0.0/24
```

### Advanced Configuration

With specific interfaces and custom naming:

```yaml
apiVersion: metallb.crossplane.io/v1alpha1
kind: MetalLBAppIPClaim
metadata:
  name: production-ip
  namespace: production
spec:
  namespace: metallb-system
  poolName: prod-pool
  addressRanges:
    - 10.100.0.0/24
    - 10.101.0.0/24
  autoAssign: true
  advertisementName: prod-l2-adv
  interfaces:
    - eth0
    - eth1
```

### Multiple Ranges

With multiple IP address ranges:

```yaml
apiVersion: metallb.crossplane.io/v1alpha1
kind: MetalLBAppIPClaim
metadata:
  name: multi-range-ip
  namespace: default
spec:
  namespace: metallb-system
  poolName: multi-pool
  addressRanges:
    - 10.0.0.0/25
    - 10.0.0.128/25
    - 10.1.0.0/24
  autoAssign: true
```

## Creating Resources

### Option 1: Direct Resource Creation

Apply the composition and XRD:

```bash
kubectl apply -f templates/xrd-metallb-app-ip.yaml
kubectl apply -f templates/composition-metallb-app-ip.yaml
```

Then create a claim:

```bash
kubectl apply -f templates/example-claim.yaml
```

### Option 2: Helm Chart Deployment

Deploy using Helm:

```bash
helm install metallb-app-ip ./metallb-apps-ip --namespace metallb-system --create-namespace
```

## Viewing Resources

### Check the claim status:

```bash
kubectl get metallbappipsclaims
kubectl describe metallbappipsclaim <claim-name>
kubectl get metallbappipsclaims -o wide
```

### View the composed resources:

```bash
# View IPAddressPool
kubectl get ipaddresspool -n metallb-system
kubectl describe ipaddresspool <pool-name> -n metallb-system

# View L2Advertisement
kubectl get l2advertisement -n metallb-system
kubectl describe l2advertisement <adv-name> -n metallb-system
```

### Watch real-time status:

```bash
kubectl get metallbappipsclaims --watch
```

## Status Indicators

The custom resource provides real-time status information:

```bash
kubectl get metallbappipsclaims -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.addressPool.ready}{"\t"}{.status.l2Advertisement.ready}{"\n"}{end}'
```

## Prerequisites

- Kubernetes 1.20+
- Crossplane 1.11+
- MetalLB 0.13+ with CRDs installed
  - `apiVersion: metallb.io/v1beta1`
  - `kind: IPAddressPool`
  - `kind: L2Advertisement`

## Composition Details

The Composition resource (`composition-metallb-app-ip.yaml`) implements the following logic:

1. **IPAddressPool Creation**: Maps the claim's `addressRanges` to the pool's `spec.addresses`
2. **Namespace Targeting**: Places both resources in the specified namespace
3. **L2Advertisement Linking**: Automatically references the created IPAddressPool
4. **Status Propagation**: Exposes the conditions and readiness state of both resources
5. **Readiness Checks**: Waits for both IPAddressPool and L2Advertisement to be ready

## Troubleshooting

### Resources not created

Check if Crossplane has permissions:

```bash
kubectl describe resourceclaim <claim-name>
kubectl logs -n crossplane-system deployment/crossplane
```

### Status not updating

Verify MetalLB resources exist:

```bash
kubectl get ipaddresspool,l2advertisement -n metallb-system
```

Check composition:

```bash
kubectl get composition
kubectl describe composition metallb-app-ip
```

### IP addresses not assigned

Verify:
1. The IPAddressPool was created correctly
2. L2Advertisement is referencing the correct pool
3. MetalLB controller has the necessary permissions

```bash
kubectl logs -n metallb-system deployment/controller
```

## Cleanup

To remove all resources created by a claim:

```bash
kubectl delete metallbappipsclaim <claim-name>
```

This will cascade-delete the composed IPAddressPool and L2Advertisement resources.

## Additional Resources

- [Crossplane Documentation](https://docs.crossplane.io/)
- [MetalLB Documentation](https://metallb.universe.tf/)
- [MetalLB CRD Reference](https://metallb.universe.tf/configuration/#layer-2-configuration)
