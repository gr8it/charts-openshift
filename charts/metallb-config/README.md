# MetalLB configuration repository

This Helm Chart prepares MetalLB configuration for APC deployment with HCP in place. 

Following resources are deployed:  

- priority class, used for metallb instance
- metallb instance
- IP address pool:
  - defines IP pools for spoke API servers
  - key `hub` in component configuration is static as the IP pools are applied on hub only
  - IP pools for individual spoke clusters are defined in component values file

    <details>

    <summary>Example of component customization</summary>
    
    ```yaml
    ipAddrPool:
      hub:
        dev01: <ip_address/pool>
        test01: <ip_address/pool>
        prod01: <ip_address/pool>
    ```

    </details>

- L2Advertisement:
  - dynamically generated objects based on configuration in component values file
- Kyverno cluster policy which will update L2Advertisement if this one have no interface configured

For more details follow [official MetalLB documentation](https://metallb.io/).  

## TODO
- once HCP gitops deployment is ready, move IPAdressPool and L2advertisement to HCP deployment/configuration part
