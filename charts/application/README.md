# Application
Reusable Helm charts for different application deployment patterns at JupiterOne

## Installing the Chart

To configure the jupiterone-apps helm repo, you'll want to run the following commands:

    helm repo add jupiterone-apps https://jupiterone.github.io/apps-helm-charts
    helm repo update

## Installation Example

To install the chart with the release name: `jupiterone-persister-example` in namespace `jupiterone-persister-example` with custom configuration specified, run the following commands:

    helm install jupiterone-persister-example jupiterone-apps/application --create-namespace --namespace jupiterone-persister-example --values ./values.yaml 

## Uninstallation Example

To uninstall the chart:

    helm delete <name-of-the-chart> -n namespace

## Unit Tests

Suites live under `charts/application/tests/`, one file per template area, and run with
the [helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin. Fixtures
shared with the PR render/Pluto/kubeconform loop live under
`charts/application/tests/fixtures/`.

    helm plugin list | grep -q unittest || helm plugin install https://github.com/helm-unittest/helm-unittest --version v1.0.3
    helm unittest charts/application

## Testing - Configuring Env/Secrets File

  vi ~/.env

  GITHUB_TOKEN=yourgithubtoken
  SRE_TEAM_SLACK_WEBHOOK=""

  vi ~/.secrets

  GITHUB_TOKEN=yourgithubtoken
  SRE_TEAM_SLACK_WEBHOOK=""

## Installing Local Tooling - Testing Github Actions

  brew install act

## Testing Github Action - PR

  act pull_request --container-architecture linux/amd64 --env-file ~/.env --secret-file ~/.secrets

## Testing Github Action - Main

  act push --container-architecture linux/amd64 --env-file ~/.env --secret-file ~/.secrets --eventpath .github/local/mocks/main-branch-mock-push-github-event.json

## Paramaters

| Name | Description                                                                                | Value                                       |
| ---| ---------------------------------------------------------------------------------------------|---------------------------------------------|
| applicationName | Name of the application                                                         | `application`                               |
| namespaceOverride | Override default release namespace with a custom value                        | `application`                               |
| labels.group | Label to define application group                                                  | `io.jupiterone.platform`                     |
| labels.team | Label to define team                                                                | `sre`                                  |

### Global label and annotation Parameters

| Name | Description | Value |
| ---| ---| ---|
| labels.chartLabels | Stamp group/team/chart/release/heritage on every object. Set `false` when live objects must carry exactly the labels you declare | `true` |
| commonLabels | Labels added to every object's metadata and every pod template | `{}` |
| commonAnnotations | Annotations added to Deployment/CronJob metadata and their pod templates | `{}` |

### Deployment Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.enabled | Enable deployment on helm chart deployments                                                        | `true`          |
| deployment.strategy | Strategy for updating deployments                                                                 | `RollingUpdate` |
| deployment.nodeSelector | Select node to deploy this application                                                        | `{}`            |
| deployment.hostAliases | Adding entries to a Pod's /etc/hosts file provides Pod-level override of hostname resolution when DNS and other options are not applicable                                                                                                                | `[]`            |
| deployment.additionalLabels | Additional labels for Deployment                                                          | `{}`            |
| deployment.podLabels | Additional label added on pod which is used in Service's Label Selector                          | {}              |
| deployment.annotations | Annotations on deployments                                                                     | `{}`            |
| deployment.additionalPodAnnotation  | Additional Pod Annotations added on pod created by this Deployment                | `{}`            |
| deployment.replicas | Replicas to be created                                                                            | ``              |
| deployment.imagePullSecrets | Secrets used to pull image                                                                | `""`            |
| deployment.env | Environment variables to be passed to the app container                                                | `{}`            |
| deployment.volumes | Volumes to be added to the pod                                                                     | `{}`            |
| deployment.volumeMounts | Mount path for Volumes                                                                        | `{}`            |
| deployment.command | Command for primary container of deployment                                                        | `[]`            |
| deployment.args | Arg for primary container of deployment                                                               | `[]`            |
| deployment.tolerations | Taint tolerations for nodes                                                                    | `[]`            |
| deployment.affinity | Affinity for pod/node                                                                             | `[]`            |
| deployment.ports | Ports for primary container                                                                          | `[]`            |
| deployment.securityContext | Security Context for the pod                                                               | `{}`            |
| deployment.additionalContainers | Add additional containers besides init and app containers                             | `[]             |

| deployment.containerName | Name of the primary container | `applicationName` |
| deployment.revisionHistoryLimit | Deployment `revisionHistoryLimit`, rendered when set | `` |
| deployment.minReadySeconds | Deployment `minReadySeconds`, rendered when set | `` |
| deployment.progressDeadlineSeconds | Deployment `progressDeadlineSeconds`, rendered when set | `` |
| deployment.priorityClassName | Pod `priorityClassName` | `` |
| deployment.terminationGracePeriodSeconds | Pod `terminationGracePeriodSeconds`, rendered when set | `` |
| deployment.automountServiceAccountToken | Pod `automountServiceAccountToken`, rendered when set | `` |
| deployment.topologySpreadConstraints | Pod topology spread constraints (templated) | `[]` |
| deployment.lifecycle | Primary container lifecycle hooks | `{}` |
| deployment.containerSecurityContext | Primary container security context | `{}` |
| deployment.envDownwardApi | Env entries from the downward API, rendered first: `[{name, fieldPath}]` | `[]` |
| deployment.envFromConfigMap | One map (`keys`) rendered as a ConfigMap (`name`, `immutable`) and as one `configMapKeyRef` entry per key | `{}` |
| deployment.envSecretKeys | `secretKeyRef` env entries rendered last: strings or `{name, key, secretName}` | `[]` |

#### Deployment Resources Parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.resources | Application pod resource requests & limits                                                       | See below       |

##### Requests and Limits

```
  resources: 
    limits:
      memory: 256Mi
      cpu: 0.5
    requests:
      memory: 128Mi
      cpu: 0.1
```

#### Deployment InitContainers Parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.initContainers | Init containers which runs before the app container                                         | `{}`            |


#### Deployment fluentd Parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.fluentdConfigAnnotations | Annotations for fluentd Configurations                                            | `{}`            |

#### Deployment Image Parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.image.repository | Image repository for the application                                                      | `repository/image-name`  |
| deployment.image.tag | Tag of the application Image                                                                     | `v1.0.0`        |
| deployment.image.pullPolicy | Pull policy for the application image                                                     | `IfNotPresent`  |

| deployment.image.ref | Complete image reference (`repository:tag` or `repository@digest`); wins over `repository`/`tag` | `""` |

#### Deployment envFrom Parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.envFrom | Environment variables to be picked from configmap or secret                                        | `{}`            |
| deployment.envFrom.type | Type of data i.e. Configmap or Secret                                                         | ``              |
| deployment.envFrom.name | Name of Configmap or Secret, if set empty, set to application name                            | ``              |
| deployment.envFrom.nameSuffix | Suffix Name of Configmap or Secret, applicationName is appended as prefix               | ``              |

#### Deployment Probes Paramaters

##### Startup Probe
StartupProbe indicates that the Pod has successfully initialized. If specified, no other probes are executed until this completes successfully.

| Name                     | Description                                                                                 | Value                  |
| ------------------------ |---------------------------------------------------------------------------------------------|------------------------|
| deployment.startupProbe.enabled | Enabled startup probe                                                                       | false                  |
| deployment.startupProbe.failureThreshold | When a probe fails, Kubernetes will try failureThreshold times before giving up.    | 30              |
| deployment.startupProbe.periodSeconds | Perform probe  everytime after specified periodSeconds                                | 10                     |
| deployment.startupProbe.successThreshold | Minimum consecutive successes for the probe to be considered successful after having failed. |                        |
| deployment.startupProbe.timeoutSeconds | Number of seconds after which the probe times out.                                    |                        |
| deployment.startupProbe.httpGet | Describes an action based on HTTP Get requests                                              | path: '/path' port: 8080 |
| deployment.startupProbe.exec | Kubelet executes the specified command to perform the probe                                 | {}          |


##### Readiness Probe
Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails.

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.readinessProbe.enabled | Enabled readiness probe                                                                  | true       |
| deployment.readinessProbe.failureThreshold | When a probe fails, Kubernetes will try failureThreshold times before giving up.                                                                  | 3      |
| deployment.readinessProbe.periodSeconds | Perform probe  everytime after specified periodSeconds                                                                  | 10       |
| deployment.readinessProbe.successThreshold | Minimum consecutive successes for the probe to be considered successful after having failed.                                                                  | 1       |
| deployment.readinessProbe.timeoutSeconds | Number of seconds after which the probe times out.                                                                  | 1       |
| deployment.readinessProbe.initialDelaySeconds | Number of seconds after the container has started before liveness or readiness probes are initiated.                                                                  | 10       |
| deployment.readinessProbe.httpGet | Describes an action based on HTTP Get requests                                                                  |   path: '/path' port: 8080     |
| deployment.readinessProbe.exec | Kubelet executes the specified command to perform the probe                                                                  |   {}   |

##### Liveness Probe
Periodic probe of container liveness. Container will be restarted if the probe fails.

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.livenessProbe.enabled | Enabled livenessProbe probe                                                                  | true       |
| deployment.livenessProbe.failureThreshold | When a probe fails, Kubernetes will try failureThreshold times before giving up.                                                                  | 3      |
| deployment.livenessProbe.periodSeconds | Perform probe  everytime after specified periodSeconds                                                                  | 10       |
| deployment.livenessProbe.successThreshold | Minimum consecutive successes for the probe to be considered successful after having failed.                                                                  | 1       |
| deployment.livenessProbe.timeoutSeconds | Number of seconds after which the probe times out.                                                                  | 1       |
| deployment.livenessProbe.initialDelaySeconds | Number of seconds after the container has started before liveness or readiness probes are initiated.                                                                  | 10       |
| deployment.livenessProbe.httpGet | Describes an action based on HTTP Get requests                                                                  |   path: '/path' port: 8080     |
| deployment.livenessProbe.exec | Kubelet executes the specified command to perform the probe                                                                  | {}      |

### Deployment Dns Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| deployment.dnsConfig | Enable pod disruption budget | `{}` |

### PodDisruptionBudget Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| pdb.enabled | Enable pod disruption budget | `false` |
| pdb.minAvailable | The number of pods that must be available after the eviction. If both minAvailable and maxUnavailable is set, minAvailable is preferred | `1`|
| pdb.maxUnavailable | The number of pods that can be unavailable after the eviction. Either minAvailable or maxUnavailable needs to be provided | `` |


| pdb.maxUnavailable | Rendered independently of `minAvailable`; set the other to `null` | `` |
| pdb.additionalLabels | Additional labels for the PDB | `{}` |

### Persistence Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| persistence.enabled | Enable persistence                                                                                                                                                                               | `false`                                                                                                                                               |
| persistence.mountPVC | Whether to mount the created PVC to the deployment                                                                                                                                               | `false`                                                                                                                                               |
| persistence.mountPath | If `persistence.mountPVC` is set, so where to mount the volume in the deployment                                                                                                                 | `/`                                                                                                                                                   |
| persistence.name | Name of the PVC.                                                                                                                | ``                                                                                                                                                   |
| persistence.accessMode | Access mode for volume                                                                                                                                                                           | `ReadWriteOnce`                                                                                                                                       |
| persistence.storageClass | StorageClass of the volume                                                                                                                                                                       | `-`                                                                                                                                                   |
| persistence.additionalLabels | Additional labels for persistent volume                                                                                                                                                          | `{}`                                                                                                                                                  |
| persistence.annotations | Annotations for persistent volume                                                                                                                                                                | `{}`                                                                                                                                                  |
| persistence.storageSize | Size of the persistent volume                                                                                                                                                                    | `8Gi`   
| persistence.volumeName | Name of the volume                                                                                                                                                                     | ``   
| persistence.volumeMode | PVC volume mode                                                                                                                                                                    | ``   

### Service Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| service.enabled | Enable service in helm chart                                                                                                                                                                    | `true`                                                                                                                                           |
| service.additionalLabels | Additional labels for service                                                                                                                                                                    | `{}`                                                                                                                                                  |
| service.annotations | Annotations for service                                                                                                                                                                          | `{}`                                                                                                                                                  |
| service.ports | Ports for applications service                                                                                                                                                                   | - port: 8080<br>&nbsp;&nbsp;name: http<br>&nbsp;&nbsp;protocol: TCP<br>&nbsp;&nbsp;targetPort: 8080                                                   |
| service.type | Type of service                                                                                                                                                                          | `ClusterIP`                                                                                                                                                  |



| service.selectorFromPodLabels | Add `deployment.podLabels` to the Service selector. `false` selects on the `app` label only | `true` |

### Ingress Paramaters

| Name | Description | Value |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| ingress.enabled | Enable ingress | `false` |
| ingress.servicePort | Port of the service that serves pod | `8080` |
| ingress.pathType | Each path in an Ingress is required to have a corresponding path type of ingress hosts to validate rules properly | `ImplementationSpecific` |
| ingress.hosts | Array of FQDN hosts to be served by this ingress | `- chart-example.local` |
| ingress.additionalLables | Labels for ingress | `{}` |
| ingress.annotations | Annotations for ingress | `{}` |
| ingress.tls | TLS block for ingress | `[]` |
| ingress.ingressClassName | Name of the ingress class | '' |

### RBAC Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| rbac.enabled | Enable RBAC                                                                                                                                                                                      | `true`                                                                                                                                                |
| rbac.serviceAccount.enabled | Enable serviceAccount                                                                                                                                                                            | `false`                                                                                                                                               |
| rbac.serviceAccount.name | Name of the existing serviceAccount                                                                                                                                                              | `""`                                                                                                                                                  |
| rbac.serviceAccount.additionalLabels | Labels for serviceAccount                                                                                                                                                                        | `{}`                                                                                                                                                  |
| rbac.serviceAccount.annotations | Annotations for serviceAccount                                                                                                                                                                   | `{}`                                                                                                                                                  |
| rbac.roles | Array of roles                                                                                                                                                                                   | `[]`                                                                                                                                                  |

| rbac.roles[].roleName | Override the Role name (`<applicationName>-role-<name>`) | `` |
| rbac.roles[].bindingName | Override the RoleBinding name (`<applicationName>-rolebinding-<name>`) | `` |
| rbac.roles[].roleLabels | Additional labels on that Role | `{}` |
| rbac.roles[].bindingLabels | Additional labels on that RoleBinding | `{}` |

### ConfigMap Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| configMap.enabled | Enable configMaps                                                                                                                                                                                | `false`                                                                                                                                               |
| configMap.additionalLabels | Labels for configMaps                                                                                                                                                                            | `{}`                                                                                                                                                  |
| configMap.annotations | Annotations for configMaps                                                                                                                                                                       | `{}`                                                                                                                                                  |
| configMap.files | Map of configMap files with suffixes and data contained in those files                                                                                                                           | `{}`                                                                                                                                                  |

### Secret Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| secret.enabled | Enable secret                                                                                                                                                                                    | `false`                                                                                                                                               |
| secret.additionalLabels | Labels for secret                                                                                                                                                                                | `{}`                                                                                                                                                  |
| secret.annotations | Annotations for secret                                                                                                                                                                           | `{}`                                                                                                                                                  |
| secret.files | Map of secret files with suffixes and data contained in those files                                                                                                                              | `{}`                                                                                                                                                  |

### ServiceMonitor Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| serviceMonitor.enabled | Enable serviceMonitor                                                                                                                                                                            | `false`                                                                                                                                               |
| serviceMonitor.additionalLabels | Labels for serviceMonitor                                                                                                                                                                        | `{}`                                                                                                                                                  |
| serviceMonitor.annotations | Annotations for serviceMonitor                                                                                                                                                                   | `{}`                                                                                                                                                  |
| serviceMonitor.release | Value of the `release` label; the Prometheus operator only selects ServiceMonitors that match | `prometheus` |
| serviceMonitor.endpoints | Array of endpoints to be scraped by prometheus                                                                                                                                                   | - interval: 5s<br>&nbsp;&nbsp;path: /metrics<br>&nbsp;&nbsp;port: http                                                                    |

### Autoscaling Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| autoscaling.enabled | Enable horizontal pod autoscaler                                                                                                                                                                 | `false`                                                                                                                                               |
| autoscaling.additionalLabels | Labels for horizontal pod autoscaler                                                                                                                                                             | `{}`                                                                                                                                                  |
| autoscaling.annotations | Annotations for horizontal pod autoscaler                                                                                                                                                        | `{}`                                                                                                                                                  |
| autoscaling.minReplicas | Sets minimum replica count when autoscaling is enabled                                                                                                                                           | `1`                                                                                                                                                   |
| autoscaling.maxReplicas | Sets maximum replica count when autoscaling is enabled                                                                                                                                           | `10`                                                                                                                                                  |
| autoscaling.metrics | Configuration for hpa metrics, set when autoscaling is enabled                                                                                                                                   | `{}`                                                                                                                                                  |

### Cert-manager Certificate Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| certificate.enabled | Enable Certificate Custom Resource                                                                                                                                                                | `false`                                                                                                                                               |
| certificate.enabled | Enable Certificate Custom Resource                                                                                                                                                                | `false`                                                                                                                                               |
| certificate.additionalLabels | Additional labels for Certificate Custom Resource                                                                                                                                                | `{}`                                                                                                                                                  |
| certificate.annotations | Annotations for Certificate Custom Resource                                                                                                                                                      | `{}`                                                                                                                                                  |
| certificate.secretName | SecretName is the name of the secret resource that will be automatically created and managed by this Certificate resource                                                                        | `tls-cert`                                                                                                                                            |
| certificate.duration | The requested ‘duration’ (i.e. lifetime) of the Certificate                                                                                                                                      | `8760h0m0s`                                                                                                                                           |
| certificate.renewBefore | The amount of time before the currently issued certificate’s notAfter time that cert-manager will begin to attempt to renew the certificate                                                      | `720h0m0s`                                                                                                                                            |
| certificate.subject | Full X509 name specification for certificate                                                                                                                                                     | `{}`                                                                                                                                                  |
| certificate.commonName | CommonName is the common name as specified on the DER encoded CSR                                                                                                                                | `admin-app`                                                                                                                                           |
| certificate.keyAlgorithm | KeyAlgorithm is the private key algorithm of the corresponding private key for this certificate                                                                                                  | `rsa`                                                                                                                                                 |
| certificate.keyEncoding | KeyEncoding is the private key cryptography standards (PKCS) for this certificate’s private key to be encoded in                                                                                 | `pkcs1`                                                                                                                                               |
| certificate.keySize | KeySize is the key bit size of the corresponding private key for this certificate                                                                                                                | `2048`                                                                                                                                                |
| certificate.isCA | IsCA will mark this Certificate as valid for certificate signing                                                                                                                                 | `false`                                                                                                                                               |
| certificate.usages | Usages is the set of x509 usages that are requested for the certificate                                                                                                                          | `{}`                                                                                                                                                  |
| certificate.dnsNames | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.                                                                                                                          | `{}`                                                                                                                                                  |
| certificate.ipAddresses | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.                                                                                                                | `{}`                                                                                                                                                  |
| certificate.uriSANs | URISANs is a list of URI subjectAltNames to be set on the Certificate.                                                                                                                           | `{}`                                                                                                                                                  |
| certificate.emailSANs | EmailSANs is a list of email subjectAltNames to be set on the Certificate.                                                                                                                       | `{}`                                                                                                                                                  |
| certificate.privateKey.enabled | Enable private key for the certificate                                                                                                                                                           | `false`                                                                                                                                               |
| certificate.privateKey.rotationPolicy | Denotes how private keys should be generated or sourced when a Certificate is being issued.                                                                                                      | `Always`                                                                                                                                              |
| certificate.issuerRef.name | IssuerRef is a reference to the issuer for this certificate. Name of the resource being referred to                                                                                              | `ca-issuer`                                                                                                                                           |
| certificate.issuerRef.kind | Kind of the resource being referred to                                                                                                                                                           | `ClusterIssuer`                                                                                                                                       |
| certificate.keystores.enabled | Enables keystore configuration. Keystores configures additional keystore output formats stored in the secretName Secret resource                                                                 | `false`                                                                                                                                               |
| certificate.keystores.pkcs12.create | Enables PKCS12 keystore creation for the Certificate. PKCS12 configures options for storing a PKCS12 keystore in the spec.secretName Secret resource                                             | `true`                                                                                                                                                |
| certificate.keystores.pkcs12.key | The key of the entry in the Secret resource’s data field to be used                                                                                                                              | `test_key`                                                                                                                                            |
| certificate.keystores.pkcs12.name | The name of the Secret resource being referred to                                                                                                                                                | `test-creds`                                                                                                                                          |
| certificate.keystores.jks.create | Enables jks keystore creation for the Certificate. JKS configures options for storing a JKS keystore in the spec.secretName Secret resource                                                      | `false`                                                                                                                                               |
| certificate.keystores.jks.key | The key of the entry in the Secret resource’s data field to be used                                                                                                                              | `test_key`                                                                                                                                            |
| certificate.keystores.jks.name | The name of the Secret resource being referred to                                                                                                                                                | `test-creds`                                                                                                                                          |

### Alertmanager Config Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| alertmanagerConfig.enabled | Enable alertmanagerConfig for this app (Will be merged in the base config)                                                                                                                       | `false`                                                                                                                                               |
| alertmanagerConfig.selectionLabels | Labels for this config to be selected for merging in alertmanager base config                                                                                                                    | `alertmanagerConfig: "workload"`                                                                                                                      |
| alertmanagerConfig.spec.route | The Alertmanager route definition for alerts matching the resource’s namespace. It will be added to the generated Alertmanager configuration as a first-level route                              | `{}`                                                                                                                                                  |
| alertmanagerConfig.spec.receivers | List of receivers                                                                                                                                                                                | `[]`                                                                                                                                                  |
| alertmanagerConfig.spec.inhibitRules | InhibitRule defines an inhibition rule that allows to mute alerts when other alerts are already firing                                                                                           | `[]`                                                                                                                                                  |

### PrometheusRule Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| prometheusRule.enabled | Enable prometheusRule for this app                                                                                                                                                               | `false`                                                                                                                                               |
| prometheusRule.additionalLabels | Kubernetes labels object, these additional labels will be added to PrometheusRule CRD                                                                                                            | `{}`                                                                                                                                                  |
| prometheusRule.spec.groups | PrometheusRules in their groups to be added                                                                                                                                                      | `[]`                                                                                                                                                  |

### NetworkPolicy Paramaters
| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| networkPolicy.enabled    | Enable NetworkPolicy                                                                         | `false`         |
| networkPolicy.additionalLabels | Kubernetes labels object                                                               | `{}`            |
| networkPolicy.annotations | Annotations for NetworkPolicy                                                               | `{}`            |
| networkPolicy.ingress | Ingress ruels for NetworkPolicy                                                                 | `[]`            |
| networkPolicy.egress | egress rules for NetworkPolicy                                                                   | `[]`            |

### Grafana Dashboard Paramaters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| grafanaDashboard.enabled | Enables Grafana Dashboard                                                                    | `false`         |
| grafanaDashboard.additionalLabels | Kubernetes labels object                                                            | `{}`            |
| grafanaDashboard.annotations | Annotations for Grafana Dashboard                                                        | `{}`            |
| grafanaDashboard.contents | Array of objects of type: - key: grafanadashboardjsoncontents                               | `[]`            |
                                                        

### VerticalPodAutoscaler Parameters

| Name | Description | Value |
| ---| ---| ---|
| vpa.enabled | Render a `VerticalPodAutoscaler` targeting the Deployment | `false` |
| vpa.name | VPA name | `<applicationName>-vpa` |
| vpa.targetRef | `{apiVersion, kind, name}` of the scaled workload | Deployment `<applicationName>` |
| vpa.updateMode | `updatePolicy.updateMode` (quoted; `Off` is recommendation-only) | `"Off"` |
| vpa.containerName | Container the bounds apply to | `"*"` |
| vpa.minAllowed / vpa.maxAllowed | Resource bounds | `{}` |
| vpa.containerPolicies | Full `containerPolicies` list; replaces the three keys above | `[]` |

### KEDA Parameters

| Name | Description | Value |
| ---| ---| ---|
| keda.enabled | Render a `ScaledObject` (and a `TriggerAuthentication`) | `false` |
| keda.name | ScaledObject name | `<applicationName>-scaler` |
| keda.scaleTargetRef | `{apiVersion, kind, name}` of the scaled workload | `<applicationName>` |
| keda.minReplicaCount / keda.maxReplicaCount | Replica bounds | `` |
| keda.pollingInterval / keda.cooldownPeriod / keda.advanced | Passed through | `` |
| keda.triggerAuthentication.enabled | Render the TriggerAuthentication and reference it from every trigger | `true` |
| keda.triggerAuthentication.name | TriggerAuthentication name | `<applicationName>-aws-credentials` |
| keda.triggerAuthentication.podIdentityProvider | `spec.podIdentity.provider` | `aws` |
| keda.triggerAuthentication.spec | Full spec, replaces `podIdentity` | `` |
| keda.triggers | Triggers rendered verbatim: `[{type, metadata, authenticationRef}]`; metadata values may use templates | `[]` |

### ExternalSecret Parameters

| Name | Description | Value |
| ---| ---| ---|
| externalSecret.enabled | Render an `ExternalSecret` | `false` |
| externalSecret.name | ExternalSecret name, also the default target Secret name | `applicationName` |
| externalSecret.refreshInterval | Refresh interval | `1h` |
| externalSecret.secretStoreRef.name / .kind | Store reference | `` / `ClusterSecretStore` |
| externalSecret.target.name / .creationPolicy / .deletionPolicy / .template | Target Secret settings | `` / `Owner` / `Retain` / `` |
| externalSecret.data | `[{secretKey, remoteRef: {key, property, version}}]`; `key` is templated; conversion/decoding/metadata strategies default to the ESO defaults so GitOps diffs stay clean | `[]` |
| externalSecret.dataFrom | Passed through | `[]` |

### TargetGroupBinding Parameters

| Name | Description | Value |
| ---| ---| ---|
| targetGroupBinding.enabled | Render an AWS Load Balancer Controller `TargetGroupBinding` | `false` |
| targetGroupBinding.name | Object name | `<applicationName>-tgb` |
| targetGroupBinding.targetGroupARN / targetGroupName | Target group, one of the two | `` |
| targetGroupBinding.targetType | `ip` or `instance` | `ip` |
| targetGroupBinding.serviceRef.name / .port | Service to bind | `applicationName` / `` |
| targetGroupBinding.networking / vpcID / nodeSelector | Passed through | `` |

### CronJob Parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| `cronJob.enabled`        | Enable cronjob in application chart                                                          | `""`            |
| `cronJob.jobs`           | cronjobs spec                                                                                | {}              |

Job paramater for each cronjob object at `cronJob.jobs` 

| Name                               | Description                                                                                  
| -----------------------------------| -------------------------------------------------------------------------------------------- |
| `<name>.schedule`                  | Schedule of cronjob                                                                          | 
| `<name>.image.repository`          | Repository of container image of cronjob                                                     |
| `<name>.image.tag`                 | Tag of container image of cronjob                                                            |
| `<name>.image.imagePullPolicy`     | ImagePullPolicy of container image ofcronjob                                                                                                                           |
| `<name>.command`                   | Command of container of job                                                                  |
| `<name>.args`                      | Args of container of job                                                                     |
| `<name>.resources`                 | Resources of container of job                                                                |
| `<name>.additionalLabels`          | Additional labels of cronjob                                                                 |
| `<name>.annotations`               | Annotation of cronjob                                                                        |    
| `<name>.successfulJobsHistoryLimit`| Successful jobs historyLimit of cronjob                                                                           |    
| `<name>.concurrencyPolicy`         | ConcurrencyPolicy of cronjob                                                                 |    
| `<name>.failedJobsHistoryLimit`    | FailedJobsHistoryLimit of cronjob                                                            |    
| `<name>.volumeMounts`              | Volume mounts  of cronjob                                                                    |  
| `<name>.volumes`                    | Volumes  of cronjob                                                                          | 
| `<name>.nodeSelector`              | Node selector of cronjob                                                                     | 
| `<name>.affinity`                  | Affinity of cronjob                                                                          | 
| `<name>.tolerations`               | Tolerations of cronjob                                                                       | 
| `<name>.restartPolicy`             | RestartPolicy of cronjob                                                                     |
| `<name>.imagePullSecrets`          | ImagePullSecrets of cronjob                                                                     |

| cronJob.jobs.NAME.timeZone / suspend / startingDeadlineSeconds | CronJob spec fields, rendered when set | `` |
| cronJob.jobs.NAME.backoffLimit / activeDeadlineSeconds / ttlSecondsAfterFinished / parallelism / completions | Job spec fields, rendered when set | `` |
| cronJob.jobs.NAME.containerName | Container name | job name |
| cronJob.jobs.NAME.podLabels / podAnnotations | Job pod template labels and annotations | `{}` |
| cronJob.jobs.NAME.jobLabels / jobAnnotations | `jobTemplate.metadata` labels and annotations | `{}` |
| cronJob.jobs.NAME.priorityClassName / terminationGracePeriodSeconds / automountServiceAccountToken / topologySpreadConstraints / securityContext / containerSecurityContext | Pod and container fields | `` |

### Job Parameters

| Name | Description | Value |
|------|-------------|-------|
| job.enabled | Render one-shot `Job`s | `false` |
| job.jobs | Map of job name to job spec; same per-job schema as `cronJob.jobs` without the schedule fields | `{}` |
| job.jobs.NAME.annotations | Job metadata annotations; set `argocd.argoproj.io/hook` / `hook-delete-policy` here to run the Job as an ArgoCD sync hook | `{}` |
| job.jobs.NAME.backoffLimit / activeDeadlineSeconds / ttlSecondsAfterFinished / parallelism / completions | Job spec fields, rendered when set | `` |
| job.jobs.NAME.restartPolicy | Pod restart policy | `Never` |
| job.jobs.NAME.envFromConfigMap | Fans out into a ConfigMap plus `configMapKeyRef` entries, like `deployment.envFromConfigMap` | `{}` |
| cronJob.jobs.NAME.envDownwardApi / envFromConfigMap / envSecretKeys | Same env model as the Deployment | `` |
| cronJob.jobs.NAME.image.ref | Complete image reference; wins over `repository`/`tag` | `` |

## Naming convention for ConfigMap and Secrets

Naming convention of type ConfigMap and Secrets is as follows: ```{{ template "application.name" $ }}-{{ $nameSuffix }}```

- ```{{ template "application.name" }}``` is a helper function that outputs ```.Values.applicationName``` if exist else return chart name as output
- `nameSuffix` is the each key in ```secret.files``` and ```configMap.files```

For example, if we have the following values file:

```
applicationName: helloworld # {{ template "application.name" $ }}

configMap:
  files:
    config: # {{ $nameSuffix }}
      key: value
```

then the configmap name will be ``helloworld-config``



## Consuming environment variable in application chart

In order to use environment variables in a deployment or cronjob, you will have to provide environment variable in *key/value* pair in `env` value. where key being environment variable key and value varies in different scenarios 

- For simple key/value environment variable, just provide `value: <value>` 
  ```
   env:
      KEY:
        value: MY_VALUE
  ```

 - To get environement variable value from **ConfigMap**
  
   Suppose we have configmap created from applicaion chart
   
   ```
   applicationName: my-application
   configMap:
     enabled: true
     files:
       application-config:
         LOG: DEBUG
         VERBOSE: v1
   ```
   To get environment variable value from above created configmap, we will need to add following
   ```
   env:
    APP_LOG_LEVEL:
     valueFrom:
       configMapKeyRef:
         name: my-application-appication-config
         key: LOG
   ```
   To get all environment variables key/values from **ConfigMap**, where configmap key being key of environment variable and value being value
   ```
     envFrom:
      application-config-env:
        type: configmap
        nameSuffix: application-config
   ```
   you can either provide `nameSuffix` which means name added after prefix ```<applicationName>-``` or static name with ```name``` of configmap.

- To get environment variable value from **Secret**
   
   Suppose we have secret created from application chart
   
   ```
    applicationName: my-application
    secret:
      enabled: true
      files:
         db-credentials:
           PASSWORD: skljd#2Qer!!
           USER: postgres
   ```
   To get environment variable value from above created secret, we will need to add following
   ```
     env:
        KEY:
         valueFrom:
          secretKeyRef:
            name: my-application-db-credentials
            key: USER
   ``` 

   To get environement variable value from **Secret**, where secret key being key of environment variable and value being value
   ```
   envFrom:
     database-credentials:
        type: secret
        nameSuffix: db-credentials
   ```
   you can either provide `nameSuffix` which means name added after prefix ```<applicationName>-``` or static name with ```name``` of secret

   **Note:** first key after ``envFrom`` is just used to uniquely identify different objects in ``envFrom`` block. Make sure to keep it unique and relevant 


### Configuring probes

By default probe handler type is `httpGet`. You just need to override `port` and `path` as per your need.

```
  livenessProbe:
    enabled: true
    httpGet:
      path: '/path'
      port: 8080
```


In order to use `exec` handler, you can define field `livenessProbe.exec` in your values.yaml.

```
  livenessProbe:
    enabled: true
    exec:
      command:
        - cat
        - /tmp/healthy
```

To disable liveness or readiness probe, set value of `enabled:` to `false`.
```
  livenessProbe:
    enabled: false
```



