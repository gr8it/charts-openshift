# createCert.sh

Easy script to generate TLS certificates for initial APC VAULT deployment.  

> !NOTE
No extra error handling in place, no extra validation of inputs in place.  

> !NOTE
Limitations: only 8 alt names allowed as of now

Requirements:

- Issuer certificate (root or intermediate certificate)
- Issuer certificate key

The script will generate certificate request configuration, certificate request, certificate itself and certificate key. Important and for later use are certificate and key.  

> !NOTE
It is suggested to use short lived certificate (certificate validation period), just enough time after the Vault configuration is done.

Created certificate should contain SANs:

- \<route> / \<ingress>, e.g. vault.apps.hub01.cloud.socpoist.sk
- vault-active.<vault-namespace>.svc, e.g vault-active.apc-vault.svc
- 127.0.0.  


Usage example:

```bash
$ ./createCert.sh
Enter the RootCA file name: ../rootCA.pem
Enter the RootCA key file name: ../rootCA.key
Enter the certificate validation period in days: 22
Enter the FQDN: skvault2.apps.ocpdemo.lab.gr8it.cloud
Enter the SANs (delimited by space): skvault2-active.skvault2.svc
Certificate request self-signature ok
subject=CN=skvault2.apps.ocpdemo.lab.gr8it.cloud
skvault2.crt: OK
Certificate verified and ready for use.
The content of certificate is:
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            12:f9:0f:b3:9f:84:a7:70:40:08:d8:50:cd:fa:e2:c4:72:cf:07:52
        Signature Algorithm: sha256WithRSAEncryption
...
...
```

Once the certificate is ready, create a secret in a namespace where vault will be deployed. Secret have to contain the generated certificate (followed by all intermediate authority certificates) and key and the issuer certificate. 

Secret example:  

```bash
oc create secret generic skvault2-tls \
   -n skvault2 \
   --from-file=skvault2.key=skvault2.key \
   --from-file=skvault2.crt=skvault2.crt \
   --from-file=rootca.crt=rootCA.pem
```
