# MongoDB configuration

Repository contains Helm chart for deploying custom MongoDB instance with use of the MongoDB Controllers for Kubernetes (MCK) Operator.  

## Configuration

Configuration is done through specifying options in values.yaml file.

### Configuration options

Most important configuration options, for full list consult values.yaml file.  

> [!IMPORTANT]
> Name of the MongoDB instance is set by the HC Release name.  

> [!NOTE]
> Some values can be overriden via the component specific value files used in GitOps approach.

| Value/Section | Default setting | Description |
|-------|---------------|-------------|
| mongodbInstance.fqdns | list | list of FQDNS for each of the replica member |
| mongodbInstance.ips | list | list of IPs for each of the replica member in CIDR format |
| mongodbInstance.replicas | 3 | Number of MongoDB replicas |
| mongodbInstance.mongoVersion | 8.2.3 | MongoDB version |
| users | list | List of users. User have to be created in Vault under path apc/<envShort>/<project_name>/mongodb/<user_function> and have to contain "username" and "password" keys |
| users.roles | list | List of MongoDB roles assigned to user |
| resourceQuotas | disabled | Specific resource quotas values if deployment has higher resource requirements than default project resource quotas |
| backup | disabled | Backup configuration of MongoDB instance |
| Monitoring | disabled | Configuration values for MongoDB monitoring |
