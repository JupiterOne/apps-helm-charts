# Changelog
All notable changes to this project will be documented here

### Unreleased
- Added a helm-unittest suite under `charts/application/tests/` covering the templates
  added in v1.1.0; `ci/*-values.yaml` fixtures moved to `charts/application/tests/fixtures/`
  and are now also used as suite-level `values:` overrides
- Fixed: `deployment.terminationGracePeriodSeconds` and `deployment.automountServiceAccountToken`
  rendered as explicit `null` by default instead of being omitted, because the template
  checked `hasKey` instead of the value itself

### v1.1.0
- CronJob moves to `batch/v1`, renders multiple jobs correctly and gains `suspend`, `timeZone`,
  `startingDeadlineSeconds`, `backoffLimit`, `activeDeadlineSeconds`, `ttlSecondsAfterFinished`,
  `parallelism`, `completions`, `podLabels`, `podAnnotations`, `containerName`, scheduling and
  security fields
- HPA moves to `autoscaling/v2`; Certificate moves to `cert-manager.io/v1`
- Deployment gains `containerName`, `revisionHistoryLimit`, `minReadySeconds`,
  `progressDeadlineSeconds`, `priorityClassName`, `terminationGracePeriodSeconds`,
  `automountServiceAccountToken`, `topologySpreadConstraints`, `lifecycle`,
  `containerSecurityContext`; `replicas: 0` renders; `resources` is free-form;
  `affinity` and probe handlers render through `tpl`; probes gain `tcpSocket`/`grpc` and
  omit unset timing fields; `volumes` no longer require `persistence`
- New env model: `envDownwardApi`, `envFromConfigMap` (one map renders both the ConfigMap
  and the per-key `configMapKeyRef` entries) and `envSecretKeys`, rendered in a fixed order
- `image.ref` accepts a complete image reference
- New templates: VerticalPodAutoscaler (`vpa`), KEDA ScaledObject + TriggerAuthentication
  (`keda`), ExternalSecret (`externalSecret`), TargetGroupBinding (`targetGroupBinding`)
- `labels.chartLabels: false` stops stamping chart provenance labels; `commonLabels` and
  `commonAnnotations` apply to every object / workload pod template
- `pdb` renders `minAvailable` and `maxUnavailable` independently and carries a namespace
- `service.selectorFromPodLabels: false` selects on the `app` label only
- RBAC roles accept `roleName`, `bindingName`, `roleLabels`, `bindingLabels`
- Fixed: the `group` label was emitted under the `team` key and `team` three times
- CI renders every `ci/*-values.yaml` fixture through Pluto and kubeconform (with CRD schemas)

### v0.0.1
- Initial release