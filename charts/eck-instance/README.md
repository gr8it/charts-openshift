# ECK instance

This repository provides helm chart for deployment of Elasticsearch and Kibana resources into the application namespace.

## Requirements

- deployed ECK operator
- specific users defined in Vault
- TLS certificate issuer for specific environments configured in Vault

##  Users

> [!IMPORTANT]
> With actually implemented ECK operator with free and basic subscription only the kubernetes basic authentication is supported.  

Elasticsearch and Kibana reuquires minimum amount of predefined users for its functionality. Login credentials and user roles are defined in specific path in Vault. Additional users can be defined afterwards.  

Specific path in Vault where users have to be defined: `apc/<env_short>/<app_namespace>/elasticsearch/<username>`  

The secret have to contain following fields:  

- username
- password
- roles (either [built-in](https://www.elastic.co/docs/reference/elasticsearch/roles) roles or custom roles)

### Requried users

Following users have to be defined in Vault:

- defaultuser  
  - function: default user for application usage  
  - required keys in sercret:  
    username: \<customer specific>  
    password: \<customer specific>  
    roles: \<customer specific or basic built-in roles `kibana_admin,ingest_admin`>  
- slmadmin  
  - function: used for backup configuration  
  - required keys in sercret:  
    username: slmadmin  
    password: \<customer specific>  
    roles: slm_admin_role  
- monitor:  
  - function: used for monitoring  
  - required keys in sercret:  
    username: monitor  
    password: \<customer specific>  
    roles: monitor_role  
- snapinit:  
  - function: used for createing the snapshot repository used for backups  
  - required keys in sercret:  
    username: snapinit  
    password: \<customer specific>  
    roles: snapshot_repo_role  

### Custom users with custom roles  

Additional users can be defined with either built-in roles or custom roles. The users are defined in component values file. 

- with built-in roles  
  - the roles are then defined in Vault in key `roles`  
  - format of user definition in component values file:  
```yaml
users:
- name: applicationuser
```
- with custom roles  
  - roles are defined inside the user definition and must be specified in vault as well  
  - format of user definition in component values file:  
```yaml
users:
  - name: monitor
    customRoles: |
      monitor_role:
        cluster:
          - "monitor"
          - "manage_slm"
          - cluster:admin/snapshot/*
          - cluster:admin/repository/get
        indices:
        - names: ["*"]
          privileges:
            - monitor
            - view_index_metadata
```

## Configuration

Helm chart provides options for Elasticsearch, Kibana and backup configuration. For further details consult [values.yaml](values.yaml). 

### Elasticsearch configuration options

| Option | Type | Default value | Description |
|--------|--------|---------------|-------------|
| route | Boolean | True | Controls the createion of route for the component |
| Version | SemVer | 9.3.1 | Sets the Elasticsearch version |
| nodesCount | Integer | 3 | Number of Elasticsearch nodes |
| requests.memory | String | 1Gi| Requested memory for Elasticsearch pods |
| requests.cpu | String | 500m| Requested CPU for Elasticsearch pods |
| limits.memory | String | 2Gi | Memory limits for Elasticsearch pods |
| limits.cpu | String | 1000m | CPU limits for Elasticsearch pods |
| volumeClaim.size | String | 100Gi | Volume size for Elasticsearch pods |
| volumeClaim.storageClass | String | ocs-storagecluster-ceph-rbd | Storgae class used for volume provisioning |

### Kibana Configuration options

| Option | Type | Default value | Description |
|--------|--------|---------------|-------------|
| route | Boolean | True | Controls the createion of route for the component |
| Version | SemVer | 9.3.1 | Sets the Kibana version |
| nodesCount | Integer | 1 | Number of Kibana nodes |
| requests.memory | String | 1Gi| Requested memory for Kibana pods |
| requests.cpu | String | 500m| Requested CPU for Kibana pods |
| limits.memory | String | 2Gi | Memory limits for Kibana pods |
| limits.cpu | String | 1000m | CPU limits for Kibana pods |

### Backup configuration options

| Option | Type | Default value | Description |
|--------|--------|---------------|-------------|
| enabled | String | True | Controls if the backup is enabled |
| s3StorageClass | String | ocs-storagecluster-ceph-rgw | Storage class used to provision S3 storage backend used for backup |
| schedule | [Quartz CRON Syntax](https://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html) | "0 30 1 * * ?" | Backup schedule |
| retention | String | 30d | Backup retention |
| min_count | Integer | 5 | Number of backups to keep at minimum |
| max_count | Integer | 50 | Number of backups to keep at maximum |

### Generic configuration options

| Option | Type | Default value | Description |
|--------|--------|---------------|-------------|
| secretStore | String | vault-hub01 | Secret store reference used to access the Vault |

## Monitoring

Monitoring is implemented with use of [Prometheus ElasticSearch Exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-elasticsearch-exporter). Generic configuraiton is done in the [values.yaml](./values.yaml) file under `prometheus-elasticsearch-exporter` section. However specific configuration for proper functionality is needed and is stored in component values file.  

Example fo component specific values:  
```yaml
prometheus-elasticsearch-exporter:
  extraEnvSecrets:
    ES_USERNAME:
      secret: {{ .Release.Name }}-monitor-user
      key: username
    ES_PASSWORD:
      secret: {{ .Release.Name }}-monitor-user
      key: password
  secretMounts:
    - name: es-tls
      secretName: {{ .Release.Name }}-es-tls
      path: /ssl
  es:
    uri: https://{{ .Release.Name }}-es-http.{{ .Release.Namespace }}.svc:9200
  serviceMonitor:
    namespace: {{ .Release.Namespace }}
```

Where:  

- `prometheus-elasticsearch-exporter.\<ES_USERNAME|ES_PASSWORD>.secret`: points to secret with `monitor` user credentials
- `prometheus-elasticsearch-exporter.secretMounts`: secret with CA, created by eck-instance helm chart
- `prometheus-elasticsearch-exporter.es.uri`: service of the elasticsearch deployment, created by eck-instance helm chart
- `prometheus-elasticsearch-exporter.serviceMonitor.namespace`: where the serviceMonitor for scraping the metrcis will be created  

Detailed configuration for ElasticSearch Exporter can be found [here](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-elasticsearch-exporter/values.yaml).


## TODO

In next phases of development following points are considered for investigation:

- replace curl api calls with k8s native tools
- consider using [internal native realm](https://www.elastic.co/docs/deploy-manage/users-roles/cluster-or-deployment-auth/native#managing-native-users) for user management
