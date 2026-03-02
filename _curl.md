## Keycloak APC

http://localhost:8080/realms/apps/protocol/openid-connect/auth?client_id=bamoe&client_secret=mPfADPxYF55WcPVUGZwaeq7d6s7iA6Qt&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%2Fcallback&scope=openid&state=state-296bc9a0-a2a2-4a57-be1a-d0e2fd9bb602


curl -X POST \
  --header 'accept: application/json' \
  --header 'authorization: Basic YmFtb2U6bVBmQURQeFlGNTVXY1BWVUdad2FlcTdkNnM3aUE2UXQ=' \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data "grant_type=authorization_code&redirect_uri=http%3A%2F%2Flocalhost%2Fcallback&code=deb066a0-aa9a-4b21-635d-c3fed194bf8d.-Z-Zpg9fvcm6nN1CX67t8Z57.dc144bdc-797d-45b2-81b7-0f90af44c59a" \
  http://localhost:8080/realms/apps/protocol/openid-connect/token

# access token:
# eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJhcGhpWnlGNkY2UUp4V2NUbVZjbWU1Q0hlYnRWREdSQXpfRVdKQ3MwdVZjIn0.eyJleHAiOjE3NzA3Mjk4NTksImlhdCI6MTc3MDcyOTU1OSwiYXV0aF90aW1lIjoxNzcwNzI4Mzc1LCJqdGkiOiJvbnJ0YWM6N2FjNmZkOGMtYzgyZi1kOWZhLWIwODItMmI4NjRhZWM1MmViIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxL3JlYWxtcy9pbnRlcm5hbCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI4ZDJjOGI3Yi04NDMyLTQ1ZTUtYjFjZi1hNTA5NTUyNTdmOTYiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJrZXljbG9hay1hcGMiLCJzaWQiOiJyaWxHdGNrb3lMZzNaQWMzeTZ4VVpPVVAiLCJhY3IiOiIwIiwiYWxsb3dlZC1vcmlnaW5zIjpbImh0dHA6Ly9sb2NhbGhvc3Q6ODA4MCJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsImRlZmF1bHQtcm9sZXMtaW50ZXJuYWwiXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6Im9wZW5pZCBlbWFpbCBwcm9maWxlIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJ1c2VyIGFkbWluIiwiZ3JvdXBzIjpbIi9hcGMtZC1icG0tYWRtaW4iXSwicHJlZmVycmVkX3VzZXJuYW1lIjoidXNlcmEiLCJnaXZlbl9uYW1lIjoidXNlciIsImZhbWlseV9uYW1lIjoiYWRtaW4iLCJlbWFpbCI6InVzZXJhQGV4YW1wbGUuY29tIn0.ckAJFtirfPv1Ehyt25gmShm0HDic468jlYvEEkTeLiQZFXSQPIQYfBMZCWnRPrzacrVMt3u-OcIs6JAP8yvoNysLbID-VyVuYNfeVjbmdcYlXoLKz7MG83EnF8pH0CM1ZRiQNSg4KstNnrEP_zWwiT_KReIKgpz93ncO61rNKrr-hdzZFD3gHu8Rq3tpDziZoDmFWxBZ_QRZGN-WwrRjKUwaGZRdT6g-8QA3NABKcwYosgWZr-WcMM1r68PeCZl9u76aQIWL76UMCjcKHiO7-XLljvcQMbcgJwOP6g8VVpVZ11ihjPcFkoSxYsrJGGh8fQraEd25YWbpq7CREz_HKQ
# 
# decoded:
# {
#   "exp": 1770729859,
#   "iat": 1770729559,
#   "auth_time": 1770728375,
#   "jti": "onrtac:7ac6fd8c-c82f-d9fa-b082-2b864aec52eb",
#   "iss": "http://localhost:8081/realms/internal",
#   "aud": "account",
#   "sub": "8d2c8b7b-8432-45e5-b1cf-a50955257f96",
#   "typ": "Bearer",
#   "azp": "keycloak-apc",
#   "sid": "rilGtckoyLg3ZAc3y6xUZOUP",
#   "acr": "0",
#   "allowed-origins": [
#     "http://localhost:8080"
#   ],
#   "realm_access": {
#     "roles": [
#       "offline_access",
#       "uma_authorization",
#       "default-roles-internal"
#     ]
#   },
#   "resource_access": {
#     "account": {
#       "roles": [
#         "manage-account",
#         "manage-account-links",
#         "view-profile"
#       ]
#     }
#   },
#   "scope": "openid email profile",
#   "email_verified": true,
#   "name": "user admin",
#   "groups": [
#     "/apc-d-bpm-admin"
#   ],
#   "preferred_username": "usera",
#   "given_name": "user",
#   "family_name": "admin",
#   "email": "usera@example.com"
# }

curl -X POST \
  --header 'authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJfcnJmM25qU2t5dlRIN0xwdjY0VEwzR0FjNy1SVFlsc2t4UGtNMGxFTGhRIn0.eyJleHAiOjE3NzA3Mjg3MDcsImlhdCI6MTc3MDcyODQwNywiYXV0aF90aW1lIjoxNzcwNzI4Mzc2LCJqdGkiOiJvbnJ0YWM6Yzg0OGI4NWEtMjQ1ZS1lMTZlLTYyMDgtZDRkOGIzNzEzMmUzIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwL3JlYWxtcy9hcHBzIiwiYXVkIjoiYnBtIiwic3ViIjoiYmYyY2QxMzktZTAzNi00ZjYxLTkwNGItOWYyZjE2M2IyMzMyIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYmFtb2UiLCJzaWQiOiI1ZHIydDZNWlJIcnJybm1JS2I2dDJoeUoiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIi8qIl0sInNjb3BlIjoib3BlbmlkIGVtYWlsIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6InVzZXIgYWRtaW4iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJ1c2VyYSIsImdpdmVuX25hbWUiOiJ1c2VyIiwiZmFtaWx5X25hbWUiOiJhZG1pbiIsImVtYWlsIjoidXNlcmFAZXhhbXBsZS5jb20ifQ.aDo3VDAb-WBnYvoaWKKkts5cuW6jIHZKf5hkGRTjUWDu0AYh19W3y3HUviy_HirA2T4BOT82BUVAkMIUElRRCZTTMjZs5AoWEOUOKQwMeG2MSZFkwNW_QuQg3eRhd6vJfqZFNDZIC8FHqY0zIms2qqpnCbJbRq2yV2b2IrV_XISOYqjcPgQ43jQ-T5YrcnuIrQ1yR9zmZ76HgmoO5Nioa-VJM0E99oLmpiANZdNfZYiAkvJdwnURYEXDg1CEDTwRxvFs4HiH5_fQ7ZL3sPm7vf1c3HEozI4O1KoAZMST8OT6uHZ8e-P8P8NMqztch-K3KJ_5XAhCI_QEanaK-SFX2g' \
  http://localhost:8080/realms/apps/protocol/openid-connect/userinfo

curl -X POST \
  --header 'authorization: Basic YmFtb2U6bVBmQURQeFlGNTVXY1BWVUdad2FlcTdkNnM3aUE2UXQ=' \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data "token=eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJfcnJmM25qU2t5dlRIN0xwdjY0VEwzR0FjNy1SVFlsc2t4UGtNMGxFTGhRIn0.eyJleHAiOjE3NzA3Mjg3MDcsImlhdCI6MTc3MDcyODQwNywiYXV0aF90aW1lIjoxNzcwNzI4Mzc2LCJqdGkiOiJvbnJ0YWM6Yzg0OGI4NWEtMjQ1ZS1lMTZlLTYyMDgtZDRkOGIzNzEzMmUzIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwL3JlYWxtcy9hcHBzIiwiYXVkIjoiYnBtIiwic3ViIjoiYmYyY2QxMzktZTAzNi00ZjYxLTkwNGItOWYyZjE2M2IyMzMyIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYmFtb2UiLCJzaWQiOiI1ZHIydDZNWlJIcnJybm1JS2I2dDJoeUoiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIi8qIl0sInNjb3BlIjoib3BlbmlkIGVtYWlsIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6InVzZXIgYWRtaW4iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJ1c2VyYSIsImdpdmVuX25hbWUiOiJ1c2VyIiwiZmFtaWx5X25hbWUiOiJhZG1pbiIsImVtYWlsIjoidXNlcmFAZXhhbXBsZS5jb20ifQ.aDo3VDAb-WBnYvoaWKKkts5cuW6jIHZKf5hkGRTjUWDu0AYh19W3y3HUviy_HirA2T4BOT82BUVAkMIUElRRCZTTMjZs5AoWEOUOKQwMeG2MSZFkwNW_QuQg3eRhd6vJfqZFNDZIC8FHqY0zIms2qqpnCbJbRq2yV2b2IrV_XISOYqjcPgQ43jQ-T5YrcnuIrQ1yR9zmZ76HgmoO5Nioa-VJM0E99oLmpiANZdNfZYiAkvJdwnURYEXDg1CEDTwRxvFs4HiH5_fQ7ZL3sPm7vf1c3HEozI4O1KoAZMST8OT6uHZ8e-P8P8NMqztch-K3KJ_5XAhCI_QEanaK-SFX2g" \
  http://localhost:8080/realms/apps/protocol/openid-connect/token/introspect

### Keyclaok SP

http://localhost:8081/realms/internal/protocol/openid-connect/auth?client_id=keycloak-apc&client_secret=9juUpmAYDL70wi89ocyKE7LjWdb1a7kW&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Frealms%2Fapps%2Fbroker%2Fkeycloak-sp%2Fendpoint&scope=openid&state=state-296bc9a0-a2a2-4a57-be1a-d0e2fd9bb602

curl -X POST \
  --header 'accept: application/json' \
  --header 'authorization: Basic a2V5Y2xvYWstYXBjOjlqdVVwbUFZREw3MHdpODlvY3lLRTdMaldkYjFhN2tX' \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data "grant_type=authorization_code&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Frealms%2Fapps%2Fbroker%2Fkeycloak-sp%2Fendpoint&code=4a9aaec2-4f56-fd34-19ee-ba1a04fd83be.rilGtckoyLg3ZAc3y6xUZOUP.8cb25b12-7453-4d27-aa68-eebec1b4520f" \
  http://localhost:8081/realms/internal/protocol/openid-connect/token

### nastavenia

#### Keycloak APC

#### Keycloak SP

- client scopes (keycloak-apc-dedicated) => Group Membership mapper => `groups` claim, Full group path, (add to ID token - vyzera, ze nie je potrebne)
- groups apps-ck-d-*, napr. apps-ck-d-bpm-reader
![groups](image-2.png)

### Logout ?!

- todo logout!

## RE

### NIE

^.*\bapc-ck-d-bpm-admin\b.*$
(?s)^.*\bapc-ck-d-bpm-admin\b.*$
(?s)^.*\b/apc-ck-d-bpm-admin\b.*$
\b/apc-d-bpm-reader\b
\b\/apc-d-bpm-reader\b
"/apc-d-bpm-reader"
"\/apc-d-bpm-reader"
\"apc-d-bpm-reader\"
\"/apc-d-bpm-reader\"
[^\w]/apc-d-bpm-reader\b
[^0-9A-Za-z-]/apc-d-bpm-reader\b
^.* /apc-d-bpm-reader\b.*$
\"\/apc-d-bpm-reader\"

### ANO

/apc-d-bpm-reader
/apc-d-bpm-reader\b
\/apc-d-bpm-reader\b
^.*/apc-d-bpm-reader\b.*$
^/apc-d-bpm-reader\b

(?<!\w)/apc-d-bpm-reader(?!\w)
