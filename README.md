# pihole

Installs pihole in kubernetes (using Carvel Tools)

## Source Code

* <https://github.com/MoJo2600/pihole-kubernetes/tree/master/charts/pihole>
* <https://pi-hole.net/>
* <https://github.com/pi-hole>
* <https://github.com/pi-hole/docker-pi-hole>

## Inspiration

This project is a rewrite of [MoJo2600/pihole-kubernetes](https://github.com/MoJo2600/pihole-kubernetes) using [Carvel](https://carvel.dev/) tools instead of Helm. I mainly wanted to get more familiar with the Carvel ecosystem and have a general interest in replacing Helm as a package manager for my home cluster.  So far, 

* [ytt](https://carvel.dev/ytt/) as a replacement for Helm's Go template engine
* [kapp](https://carvel.dev/kapp/) as the orchestrator for deploying/managing the chart
* [kapp-controller](https://carvel.dev/kapp-controller/) as the packaging/versioning manager

## Installation

Currently this chart can be deploy two ways:

Purely with `ytt`: 
```bash
ytt -f values.yaml -f templates/ | kubectl apply -f-
```

Or with `kapp`:
```bash
kapp -y deploy -a pihole -f <(ytt -f values.yaml -f templates/)
```

### Configure the chart

The following items can be configured by editing the `values.yaml` directly.

#### Configure the way how to expose pihole service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.

## Configuring Upstream DNS Resolvers

By default, `carvel-pihole` will configure pod DNS automatically to use Google's `8.8.8.8` nameserver for upstream
DNS resolution. You can configure this, or opt-out of pod DNS configuration completely.

### Changing The Upstream DNS Resolver

For example, to use Cloudflare's resolver:

```yaml
podDnsConfig:
  enabled: true
  policy: "None"
  nameservers:
  - 127.0.0.1
  - 1.1.1.1
```

### Disabling Pod DNS Configuration

If you have other DNS policy at play (for example, when running a service mesh), you may not want to have
`carvel-pihole` control this behavior. In that case, you can disable DNS configuration on `pihole` pods:

```yaml
podDnsConfig:
  enabled: false
```

## Uninstallation

```bash
ytt -f values.yaml -f templates/ | kubectl delete -f-
```

```bash
kapp delete -a pihole
```

## Configuration

The following table lists the configurable parameters of the pihole chart and the default values.

## Values

NOTE: while authoritative for the most part, some values/types have been adjusted to better work with `ytt`.  Please check out commented examples in the `value.yaml` file to see where those changes are. I will go through this list an update it at some later date.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| DNS1 | string | `"8.8.8.8"` | default upstream DNS 1 server to use |
| DNS2 | string | `"8.8.4.4"` | default upstream DNS 2 server to use |
| adlists | object | `{}` | list of adlists to import during initial start of the container |
| admin | object | `{"existingSecret":"","passwordKey":"password"}` | Use an existing secret for the admin password. |
| admin.existingSecret | string | `""` | Specify an existing secret to use as admin password |
| admin.passwordKey | string | `"password"` | Specify the key inside the secret to use |
| adminPassword | string | `"admin"` | Administrator password when not using an existing secret (see below) |
| affinity | object | `{}` |  |
| antiaff.avoidRelease | string | `"pihole1"` | Here you can set the pihole release (you set in `helm install <releasename> ...`) you want to avoid |
| antiaff.enabled | bool | `false` | set to true to enable antiaffinity (example: 2 pihole DNS in the same cluster) |
| antiaff.strict | bool | `true` | Here you can choose between preferred or required |
| blacklist | object | `{}` | list of blacklisted domains to import during initial start of the container |
| customVolumes.config | object | `{}` | any volume type can be used here |
| customVolumes.enabled | bool | `false` | set this to true to enable custom volumes |
| dnsHostPort.enabled | bool | `false` | set this to true to enable dnsHostPort |
| dnsHostPort.port | int | `53` | default port for this pod |
| dnsmasq.additionalHostsEntries | list | `[]` | Dnsmasq reads the /etc/hosts file to resolve ips. You can add additional entries if you like |
| dnsmasq.customCnameEntries | list | `[]` | Here we specify custom cname entries that should point to `A` records or elements in customDnsEntries array. The format should be:  - cname=cname.foo.bar,foo.bar  - cname=cname.bar.foo,bar.foo  - cname=cname record,dns record |
| dnsmasq.customDnsEntries | list | `[]` | Add custom dns entries to override the dns resolution. All lines will be added to the pihole dnsmasq configuration. |
| dnsmasq.customSettings | string | `nil` | Other options |
| dnsmasq.staticDhcpEntries | list | `[]` | Static DHCP config |
| dnsmasq.upstreamServers | list | `[]` | Add upstream dns servers. All lines will be added to the pihole dnsmasq configuration |
| doh.enabled | bool | `false` | set to true to enabled DNS over HTTPs via cloudflared |
| doh.envVars | object | `{}` | Here you can pass environment variables to the DoH container, for example: |
| doh.name | string | `"cloudflared"` |  |
| doh.probes | object | `{"liveness":{"enabled":true,"failureThreshold":10,"initialDelaySeconds":60,"probe":{"exec":{"command":["nslookup","-po=5053","cloudflare.com","127.0.0.1"]}},"timeoutSeconds":5}}` | Probes configuration |
| doh.probes.liveness | object | `{"enabled":true,"failureThreshold":10,"initialDelaySeconds":60,"probe":{"exec":{"command":["nslookup","-po=5053","cloudflare.com","127.0.0.1"]}},"timeoutSeconds":5}` | Configure the healthcheck for the doh container |
| doh.probes.liveness.enabled | bool | `true` | set to true to enable liveness probe |
| doh.probes.liveness.failureThreshold | int | `10` | defines the failure threshold for the liveness probe |
| doh.probes.liveness.initialDelaySeconds | int | `60` | defines the initial delay for the liveness probe |
| doh.probes.liveness.probe | object | `{"exec":{"command":["nslookup","-po=5053","cloudflare.com","127.0.0.1"]}}` | customize the liveness probe |
| doh.probes.liveness.timeoutSeconds | int | `5` | defines the timeout in secondes for the liveness probe |
| doh.pullPolicy | string | `"IfNotPresent"` |  |
| doh.repository | string | `"crazymax/cloudflared"` |  |
| doh.tag | string | `"latest"` |  |
| dualStack.enabled | bool | `false` | set this to true to enable creation of DualStack services or creation of separate IPv6 services if `serviceDns.type` is set to `"LoadBalancer"` |
| extraEnvVars | object | `{}` | extraEnvironmentVars is a list of extra enviroment variables to set for pihole to use |
| extraEnvVarsSecret | object | `{}` | extraEnvVarsSecret is a list of secrets to load in as environment variables. |
| extraVolumeMounts | object | `{}` | any extra volume mounts you might want |
| extraVolumes | object | `{}` | any extra volumes you might want |
| ftl | object | `{}` | values that should be added to pihole-FTL.conf |
| hostNetwork | string | `"false"` | should the container use host network |
| hostname | string | `""` | hostname of pod |
| image.pullPolicy | string | `"IfNotPresent"` | the pull policy |
| image.repository | string | `"pihole/pihole"` | the repostory to pull the image from |
| image.tag | string | `""` | the docker tag, if left empty it will get it from the chart's appVersion |
| ingress | object | `{"annotations":{},"enabled":false,"hosts":["chart-example.local"],"path":"/","tls":[]}` | Configuration for the Ingress |
| ingress.annotations | object | `{}` | Annotations for the ingress |
| ingress.enabled | bool | `false` | Generate a Ingress resource |
| maxSurge | int | `1` | The maximum number of Pods that can be created over the desired number of `ReplicaSet` during updating. |
| maxUnavailable | int | `1` | The maximum number of Pods that can be unavailable during updating |
| monitoring.podMonitor | object | `{"enabled":false}` | Preferably adding prometheus scrape annotations rather than enabling podMonitor. |
| monitoring.podMonitor.enabled | bool | `false` | set this to true to enable podMonitor |
| monitoring.sidecar | object | `{"enabled":false,"image":{"pullPolicy":"IfNotPresent","repository":"ekofr/pihole-exporter","tag":"v0.3.0"},"port":9617,"resources":{"limits":{"memory":"128Mi"}}}` | Sidecar configuration |
| monitoring.sidecar.enabled | bool | `false` | set this to true to enable podMonitor as sidecar |
| nodeSelector | object | `{}` |  |
| persistentVolumeClaim | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"size":"500Mi"}` | `spec.PersitentVolumeClaim` configuration |
| persistentVolumeClaim.annotations | object | `{}` | Annotations for the `PersitentVolumeClaim` |
| persistentVolumeClaim.enabled | bool | `false` | set to true to use pvc |
| podAnnotations | object | `{}` | Additional annotations for pods |
| podDnsConfig.enabled | bool | `true` |  |
| podDnsConfig.nameservers[0] | string | `"127.0.0.1"` |  |
| podDnsConfig.nameservers[1] | string | `"8.8.8.8"` |  |
| podDnsConfig.policy | string | `"None"` |  |
| privileged | string | `"false"` | should container run in privileged mode |
| probes | object | `{"liveness":{"enabled":true,"failureThreshold":10,"initialDelaySeconds":60,"port":"http","scheme":"HTTP","timeoutSeconds":5},"readiness":{"enabled":true,"failureThreshold":3,"initialDelaySeconds":60,"port":"http","scheme":"HTTP","timeoutSeconds":5}}` | Probes configuration |
| probes.liveness.enabled | bool | `true` | Generate a liveness probe |
| probes.readiness.enabled | bool | `true` | Generate a readiness probe |
| regex | object | `{}` | list of blacklisted regex expressions to import during initial start of the container |
| replicaCount | int | `1` | The number of replicas |
| resources | object | `{}` | lines, adjust them as necessary, and remove the curly braces after 'resources:'. |
| serviceDhcp | object | `{"annotations":{},"enabled":true,"externalTrafficPolicy":"Local","loadBalancerIP":"","loadBalancerIPv6":"","nodePort":"","port":67,"type":"NodePort"}` | Configuration for the DHCP service on port 67 |
| serviceDhcp.annotations | object | `{}` | Annotations for the DHCP service |
| serviceDhcp.enabled | bool | `true` | Generate a Service resource for DHCP traffic |
| serviceDhcp.externalTrafficPolicy | string | `"Local"` | `spec.externalTrafficPolicy` for the DHCP Service |
| serviceDhcp.loadBalancerIP | string | `""` | A fixed `spec.loadBalancerIP` for the DHCP Service |
| serviceDhcp.loadBalancerIPv6 | string | `""` | A fixed `spec.loadBalancerIP` for the IPv6 DHCP Service |
| serviceDhcp.nodePort | string | `""` | Optional node port for the DHCP service |
| serviceDhcp.port | int | `67` | The port of the DHCP service |
| serviceDhcp.type | string | `"NodePort"` | `spec.type` for the DHCP Service |
| serviceDns | object | `{"annotations":{},"externalTrafficPolicy":"Local","loadBalancerIP":"","loadBalancerIPv6":"","mixedService":false,"nodePort":"","port":53,"type":"NodePort"}` | Configuration for the DNS service on port 53 |
| serviceDns.annotations | object | `{}` | Annotations for the DNS service |
| serviceDns.externalTrafficPolicy | string | `"Local"` | `spec.externalTrafficPolicy` for the DHCP Service |
| serviceDns.loadBalancerIP | string | `""` | A fixed `spec.loadBalancerIP` for the DNS Service |
| serviceDns.loadBalancerIPv6 | string | `""` | A fixed `spec.loadBalancerIP` for the IPv6 DNS Service |
| serviceDns.mixedService | bool | `false` | deploys a mixed (TCP + UDP) Service instead of separate ones |
| serviceDns.nodePort | string | `""` | Optional node port for the DNS service |
| serviceDns.port | int | `53` | The port of the DNS service |
| serviceDns.type | string | `"NodePort"` | `spec.type` for the DNS Service |
| serviceWeb | object | `{"annotations":{},"externalTrafficPolicy":"Local","http":{"enabled":true,"nodePort":"","port":80},"https":{"enabled":true,"nodePort":"","port":443},"loadBalancerIP":"","loadBalancerIPv6":"","type":"ClusterIP"}` | Configuration for the web interface service |
| serviceWeb.annotations | object | `{}` | Annotations for the DHCP service |
| serviceWeb.externalTrafficPolicy | string | `"Local"` | `spec.externalTrafficPolicy` for the web interface Service |
| serviceWeb.http | object | `{"enabled":true,"nodePort":"","port":80}` | Configuration for the HTTP web interface listener |
| serviceWeb.http.enabled | bool | `true` | Generate a service for HTTP traffic |
| serviceWeb.http.nodePort | string | `""` | Optional node port for the web HTTP service |
| serviceWeb.http.port | int | `80` | The port of the web HTTP service |
| serviceWeb.https | object | `{"enabled":true,"nodePort":"","port":443}` | Configuration for the HTTPS web interface listener |
| serviceWeb.https.enabled | bool | `true` | Generate a service for HTTPS traffic |
| serviceWeb.https.nodePort | string | `""` | Optional node port for the web HTTPS service |
| serviceWeb.https.port | int | `443` | The port of the web HTTPS service |
| serviceWeb.loadBalancerIP | string | `""` | A fixed `spec.loadBalancerIP` for the web interface Service |
| serviceWeb.loadBalancerIPv6 | string | `""` | A fixed `spec.loadBalancerIP` for the IPv6 web interface Service |
| serviceWeb.type | string | `"ClusterIP"` | `spec.type` for the web interface Service |
| strategyType | string | `"RollingUpdate"` | The `spec.strategyTpye` for updates |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` | Specify a priorityClassName priorityClassName: "" Reference: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/ |
| virtualHost | string | `"pi.hole"` |  |
| webHttp | string | `"80"` | port the container should use to expose HTTP traffic |
| webHttps | string | `"443"` | port the container should use to expose HTTPS traffic |
| whitelist | object | `{}` | list of whitelisted domains to import during initial start of the container |

## Maintainers

| Name | Keybase | Mastodon |
| ---- | ------ | --- |
| slapula | ajsmith | tbd |
