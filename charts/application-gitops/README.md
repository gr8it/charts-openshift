# Application Gitops

```mermaid
 flowchart TD
    u@{ shape: manual-input, label: "User"}

    subgraph apc

        subgraph na[Application namespace]
            naa[ArgoCD Application CR]
        end

        subgraph ng[Gitops namespace]
            ngsr[Repository secret]
            ngap[ArgoCD Project]
            a[ArgoCD]
        end
    end

    u -- self service management --> naa
    u -- self service management of repository (credentials) --> a
    a --> ngsr

    naa -. on application creation Kyverno policy creates .-> ngap
    ngap -. allows usage of project in application namespace ....-> naa
```

Component allows self service of application gitops by app teams:

1) User creates ArgoCD application in application namespace, e.g.

   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: moodle
     namespace: moodle
   spec:
     destination:
       namespace: moodle
       server: https://kubernetes.default.svc
     project: moodle
     source:
       helm:
         releaseName: moodle
         valueFiles:
           - ../../values.dev.yaml
       path: charts/apc-moodle
       repoURL: https://github.com/gr8it/moodle.git
       targetRevision: HEAD
   ```

> [!NOTE]  
> Uses [App in any namespace](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/) feature

2) APC creates an ArgoCD Appproject with the same name as the application namespace where ArgoCD Application was created in

3) APC sets up dedicated service account with admin role, which is used for deployment of resources to the application namespace

4) User creates a repository with credentials in ArgoCD

## RBAC

- project from namespace matching the app project name only
- pja / opr / tes / dev / vie ... roles aligned to their kubernetes counterparts
  
  |role|applications|repositories|resources|exec|logs|
  |---|---|---|---|---|---|
  |PJA|FULL|YES|FULL|YES|YES|
  |OPR|READ|YES|FULL|YES|YES|
  |TES**|READ|NO|FULL|YES|YES|
  |DEV**|READ|NO|FULL|YES|YES|
  |VIE|READ|NO|NO|NO|NO|

  ** dev and test environments only

  > Where:  
  > role = APC project role  
  > applications = management of the ArgoCD application  
  > repositories = management of the ArgoCD project git repository  
  > resources = management of the resources deployed by ArgoCD, including sync and lifecycle management  
  > exec = exec into pod
  > logs = view logs

  <https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#the-applications-resource>

- gitlab.socpoist.sk repo only
- 1 namespace = 1 application = 1 app project

- all git users are ~ project admins! musia sa silno zamysliet, ako si vyriesit opravnenia => admin by mal schvalovat merge do main !?

- service account role same to the project administrator (PJA)

  > [!NOTE]  
  > Uses alpha feature [Application Sync using impersonation](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-sync-using-impersonation/)
