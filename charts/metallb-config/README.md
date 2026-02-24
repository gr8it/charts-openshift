# MetalLB configuration repository

This Helm Chart prepares MetalLB configuration for APC deployment with HCP in place. 

Following resources are deployed:  

- priority class, used for metallb instance
- metallb instance
- IP address pool:
  - defines IP pools for spoke API servers
  - key ```hub``` in component configruation is static as the IP pools are appiled on hub only
  - IP pools for individual spoke clusters are define in component values file

    <details>

    <summary>Example of component customization</summary>
    
    ipAddrPool:  
      hub:  
        dev01: <ip_address/pool>  
        test01: <ip_address/pool>  
        prod01: <ip_address/pool> 
    
    </details>

- L2Advertisement:
  - dynamicaly generated objects based on configuration in component values file
- Kyverno cluster policy which will update L2Advertisement if this one have no interface configured

For more details follow [official MetalLB documentation](https://metallb.io/).  

## TODO
- once HCP gitops deployemnt is ready, move IPAdressPool and L2advertisement to HCP deployment/configuration part
