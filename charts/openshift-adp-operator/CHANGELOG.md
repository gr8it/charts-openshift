# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-11-05

- Point the operator at OADP v1.5.8 on channel `stable`. `upgradeApproval` is `Automatic`, so ACM approves the InstallPlan when its CSV is listed in `versions`. The `stable-1.4` channel does not exist in the OCP 4.19 catalog. OADP 1.5 is supported on OCP 4.19 only.
- Keep `oadp-operator.v1.4.3` in the allowed versions during the upgrade.
