# APC Gatling Operator

Gatling Operator is a Kubernetes Operator for running automated distributed Gatling load testing.

Following helm chart is able to install community version of [Gatling operator](https://github.com/st-tech/gatling-operator/tree/main)

Helm chart is built from [Gatling operator quickstart](https://github.com/st-tech/gatling-operator/blob/main/docs/quickstart-guide.md)


## Additional components

Additional to [Gatling operator quickstart](https://github.com/st-tech/gatling-operator/blob/main/docs/quickstart-guide.md) following resources are deployed:
- clusterrole-project-admin.yaml - aggregates full permissions for gatling resources to project admin, developer, tester, operator cluster roles 
- clusterrole-project-view.yaml - aggregates view permissions for gatling resources to project view cluster role

