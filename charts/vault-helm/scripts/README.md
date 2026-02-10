# createCert.sh

Easy script to generate TLS certificates for initial APC VAULT deployment.  

> !NOTE
No extra error handling in place, no extra validation of inputs in place.  

> !NOTE
Limitations: only 8 alt names allowed as of now

Requirements:

- Issuer certificate (root or intermediate certificate), from the organization for which the vault is deployed
- Issuer certificate key, from the organization for which the vault is deployed

The script will generate certificate request configuration, certificate request, certificate itself and certificate key. Important and for later use are certificate and key.  

> !NOTE
It is suggested to use short lived certificate (certificate validation period), just enough time after the Vault configuration is done.

Created certificate should contain SANs:

- \<route> / \<ingress>, e.g. vault.apps.hub01.cloud.example.com
- vault-active.<vault-namespace>.svc, e.g vault-active.apc-vault.svc
- 127.0.0.1 (in scripted solution this one is inserted automatically, no need to specify) 


Usage example:

```bash
$ ./createCert.sh
Enter the RootCA file name: ../rootCA.pem
Enter the RootCA key file name: ../rootCA.key
Enter the certificate validation period in days: 22
Enter the FQDN: vault.apps.ocpdemo.lab.example.com
Enter the SANs (delimited by space): vault-active.apc-vault.svc
Certificate request self-signature ok
subject=CN=vault.apps.ocpdemo.lab.example.com
vault.crt: OK
Certificate verified and ready for use.
The content of certificate is:
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            12:f9:0f:b3:9f:84:a7:70:40:08:d8:50:cd:fa:e2:c4:72:cf:07:57
        Signature Algorithm: sha256WithRSAEncryption
...
...
```

Once the certificate is ready, create a secret in a namespace where vault will be deployed. Secret have to contain the generated certificate (followed by all intermediate authority certificates) and key and the issuer certificate. 

Secret example:  

```bash
oc create secret generic vault-tls-cert \
   -n apc-vault \
   --from-file=tls.key=vault.key \
   --from-file=tls.crt=vault.crt \
   --from-file=ca.crt=../rootCA.pem
```
