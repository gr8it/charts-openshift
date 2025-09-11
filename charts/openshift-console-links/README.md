## ConsoleLinks Chart

### Usage

Define console links in your `values.yaml` under the `links` key.  
Each link should include `name`, `href`, `location`, and `text`.

[Ref. documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/console_apis/consolelink-console-openshift-io-v1#spec-3)


Example:

```yaml
links:
  - name: user-guide
    href: 'https://user-guide-apc-guides.apps.hub01.cloud.socpoist.sk/'
    location: HelpMenu
    text: APC používateľská príručka
```

This will create a ConsoleLink resource for each entry.