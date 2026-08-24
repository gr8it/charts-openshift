ACTION_LOG_ARCHIVE_LOCATION: local_us
ACTION_LOG_ARCHIVE_PATH: archive/logs
ACTION_LOG_ROTATION_THRESHOLD: {{ .Values.quayConfig.actionLogRetention }}
ALLOW_PULLS_WITHOUT_STRICT_LOGGING: false
AUTHENTICATION_TYPE: Database
BOOTSTRAP_TOKEN_OWNER: {{ .Values.quayConfig.localAdminUser }}
BOOTSTRAP_TOKEN_EXPIRATION: 7200
{{/* BOOTSTRAP_TOKEN_EXPIRATION: 7776000 */}}
BOOTSTRAP_TOKEN_SCOPE: "org:admin repo:admin repo:create repo:read repo:write super:user user:admin user:read"
CREATE_PRIVATE_REPO_ON_PUSH: false
DEFAULT_TAG_EXPIRATION: {{ .Values.quayConfig.tagExpiration }}
ENTERPRISE_LOGO_URL: /static/img/RH_Logo_Quay_Black_UX-horizontal.svg
FEATURE_ACTION_LOG_ROTATION: true
FEATURE_BUILD_SUPPORT: false
FEATURE_DIRECT_LOGIN: true
FEATURE_MAILING: false
FEATURE_PROGRAMMATIC_BOOTSTRAP: true
FEATURE_PROXY_CACHE: true
FEATURE_UI_V2: true
FEATURE_USER_CREATION: false
FEATURE_USER_INITIALIZE: true
{{/* PROGRAMMATIC_TOKEN_K8S_SECRET: foo */}}
{{/* PROGRAMMATIC_TOKEN_K8S_KEY: bar */}}
REGISTRY_TITLE: {{ .Values.quayConfig.registryTitle }}
REGISTRY_TITLE_SHORT: {{ .Values.quayConfig.registryTitleShort }}
SETUP_COMPLETE: true
SUPER_USERS:
  {{ printf "- %s" .Values.quayConfig.localAdminUser }}
TAG_EXPIRATION_OPTIONS:
  {{- .Values.quayConfig.tagExpirationOptions | toYaml | nindent 2 }}
TEAM_RESYNC_STALE_TIME: 60m
TESTING: false
