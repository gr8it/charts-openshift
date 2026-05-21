# C:\Scripts\CONFIG.ps1
$Config = @{
    GROUP = 'xxx' # set in customer GitOps copy, for example 'veeam01'
    BASE_URL = 'https://prometheus-pushgateway-prometheus-pushgateway.apps.clusterx.xx.domain.sk' # set in customer GitOps copy, for example 'https://pushgateway.example.cloud'
    SERVER = $env:COMPUTERNAME
    JobRunVisualizationWindowSeconds = '' # align with scheduled task interval, for example '1800'
}
