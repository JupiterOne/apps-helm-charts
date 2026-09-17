{{/*
Define the name of the chart/application.
Usage:
{{ include "application.name" . }}
*/}}
{{- define "application.name" -}}
{{- default .Chart.Name .Values.applicationName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Includes an application label selector to select this application
Usage:
{{ include "application.labels.selector" . }}
*/}}
{{- define "application.labels.selector" -}}
app: {{ template "application.name" . }}
{{- end -}}

{{/*
Includes application labels for this helm chart
Usage:
{{ include "application.labels" . }}
*/}}
{{- define "application.labels" -}}
{{ template "application.labels.selector" . }}
appVersion: "{{ .Values.deployment.image.tag | trunc 63 | trimSuffix "-" -}}"
{{- end -}}

{{/*
Includes application team labels for this helm chart
Usage:
{{ include "application.labels.team" . }}
*/}}
{{- define "application.labels.team" -}}
team: {{ .Values.labels.team }}
{{- end -}}

{{/*
Includes application group labels for this helm chart
Usage:
{{ include "application.labels.group" . }}
*/}}
{{- define "application.labels.group" -}}
group: {{ .Values.labels.group }}
{{- end -}}

{{/*
Chart-provenance labels (group, team, chart, release, heritage). Stamped on every object
unless labels.chartLabels is false, for consumers whose live objects must not carry them.
Usage:
{{ include "application.labels.chart" . }}
*/}}
{{- define "application.labels.chart" -}}
{{- if or (not (hasKey .Values.labels "chartLabels")) .Values.labels.chartLabels -}}
group: {{ .Values.labels.group }}
team: {{ .Values.labels.team }}
chart: "{{ .Chart.Name }}"
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end }}
{{- end -}}

{{/*
Labels for every object's metadata: chart labels (when enabled) plus commonLabels.
Usage:
{{ include "application.labels.metadata" . | indent 4 }}
*/}}
{{- define "application.labels.metadata" -}}
{{- $chart := include "application.labels.chart" . -}}
{{- $lines := list -}}
{{- if $chart }}{{ $lines = append $lines $chart }}{{ end -}}
{{- range $k, $v := .Values.commonLabels -}}
{{- $lines = append $lines (printf "%s: %s" $k ($v | quote)) -}}
{{- end -}}
{{- if not $lines }}{{ $lines = append $lines (include "application.labels.selector" .) }}{{ end -}}
{{ join "\n" $lines }}
{{- end -}}

{{/*
Pod template labels: the selector label, commonLabels, then the workload's own podLabels.
`app` is seeded from the application name and always wins so pods can never drift away
from the immutable selector.
Usage:
{{ include "application.labels.pod" (dict "root" $ "podLabels" .Values.deployment.podLabels) | indent 8 }}
*/}}
{{- define "application.labels.pod" -}}
{{- $root := .root -}}
{{- $labels := merge (dict "app" (include "application.name" $root)) (default (dict) .podLabels) (default (dict) $root.Values.commonLabels) -}}
{{- range $k, $v := $labels }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "application.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "application.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Namespace of this deployed helm chart
Usage:
{{ include "application.namespace" . }}
*/}}
{{- define "application.namespace" -}}
        {{- if .Values.namespaceOverride }}
            {{- .Values.namespaceOverride -}}
        {{- else -}}
            {{- .Release.Namespace -}}
        {{- end -}}
{{- end }}

{{/*
Container image reference. image.ref (a complete "repository:tag" or "repository@digest"
string) wins over the repository/tag pair, so tooling that writes back whole references
(ArgoCD Image Updater) needs a single key.
Usage:
{{ include "application.image" .Values.deployment.image }}
*/}}
{{- define "application.image" -}}
{{- if .ref -}}
{{ .ref }}
{{- else -}}
{{ .repository }}:{{ .tag }}
{{- end -}}
{{- end -}}

{{/*
Service account name used by pods: rbac.serviceAccount.name or the application name.
*/}}
{{- define "application.serviceAccountName" -}}
{{- default (include "application.name" .) .Values.rbac.serviceAccount.name -}}
{{- end -}}

{{/*
Container env list for a workload (Deployment or one CronJob job), in a fixed order:
  1. envDownwardApi  - fieldRef entries, in list order
  2. envFromConfigMap - one configMapKeyRef per key of the fanned-out ConfigMap (sorted)
  3. env             - free-form entries (value / valueFrom), sorted by name
  4. envSecretKeys   - secretKeyRef entries, in list order
Usage:
{{ include "application.env" (dict "root" $ "workload" .Values.deployment "name" (include "application.name" $)) | indent 8 }}
*/}}
{{- define "application.env" -}}
{{- $root := .root -}}
{{- $w := .workload -}}
{{- $name := .name -}}
{{- range $w.envDownwardApi }}
- name: {{ .name }}
  valueFrom:
    fieldRef:
      apiVersion: {{ .apiVersion | default "v1" }}
      fieldPath: {{ .fieldPath }}
{{- end }}
{{- with $w.envFromConfigMap }}
{{- if or (not (hasKey . "enabled")) .enabled }}
{{- $cmName := .name | default $name }}
{{- range $k, $v := .keys }}
- name: {{ $k }}
  valueFrom:
    configMapKeyRef:
      key: {{ $k }}
      name: {{ $cmName }}
      optional: {{ $.workload.envFromConfigMap.optional | default false }}
{{- end }}
{{- end }}
{{- end }}
{{- range $key, $value := $w.env }}
- name: {{ include "application.tplvalues.render" ( dict "value" $key "context" $root ) }}
{{ include "application.tplvalues.render" ( dict "value" $value "context" $root ) | indent 2 }}
{{- end }}
{{- range $w.envSecretKeys }}
{{- $entry := . }}
{{- if kindIs "string" $entry }}{{ $entry = dict "name" $entry }}{{ end }}
- name: {{ $entry.name }}
  valueFrom:
    secretKeyRef:
      key: {{ $entry.key | default $entry.name }}
      name: {{ $entry.secretName | default (($root.Values.externalSecret).name | default $name) }}
      optional: {{ $entry.optional | default false }}
{{- end }}
{{- end -}}

{{/*
A single probe. Numeric fields render only when set; the handler (exec, httpGet, tcpSocket
or grpc) is rendered through tpl so paths can reference values.
Usage:
{{ include "application.probe" (dict "probe" .Values.deployment.livenessProbe "context" $) | indent 10 }}
*/}}
{{- define "application.probe" -}}
{{- $p := .probe -}}
{{- $ctx := .context -}}
{{- with $p.failureThreshold }}
failureThreshold: {{ . }}
{{- end }}
{{- with $p.periodSeconds }}
periodSeconds: {{ . }}
{{- end }}
{{- with $p.successThreshold }}
successThreshold: {{ . }}
{{- end }}
{{- with $p.timeoutSeconds }}
timeoutSeconds: {{ . }}
{{- end }}
{{- with $p.initialDelaySeconds }}
initialDelaySeconds: {{ . }}
{{- end }}
{{- with $p.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
{{- if $p.exec }}
exec:
  {{- include "application.tplvalues.render" (dict "value" $p.exec "context" $ctx) | nindent 2 }}
{{- else if $p.httpGet }}
httpGet:
  {{- include "application.tplvalues.render" (dict "value" $p.httpGet "context" $ctx) | nindent 2 }}
{{- else if $p.tcpSocket }}
tcpSocket:
  {{- include "application.tplvalues.render" (dict "value" $p.tcpSocket "context" $ctx) | nindent 2 }}
{{- else if $p.grpc }}
grpc:
  {{- include "application.tplvalues.render" (dict "value" $p.grpc "context" $ctx) | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Pod-level scheduling and lifecycle fields shared by the Deployment pod template and CronJob
job pod templates. Rendered at the indentation of the pod spec.
Usage:
{{ include "application.podSpecCommon" (dict "root" $ "workload" .Values.deployment) | indent 6 }}
*/}}
{{- define "application.podSpecCommon" -}}
{{- $root := .root -}}
{{- $w := .workload -}}
{{- with $w.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- if not (kindIs "invalid" $w.terminationGracePeriodSeconds) }}
terminationGracePeriodSeconds: {{ $w.terminationGracePeriodSeconds }}
{{- end }}
{{- if not (kindIs "invalid" $w.automountServiceAccountToken) }}
automountServiceAccountToken: {{ $w.automountServiceAccountToken }}
{{- end }}
{{- with $w.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $w.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $w.affinity }}
affinity:
  {{- include "application.tplvalues.render" (dict "value" . "context" $root) | nindent 2 }}
{{- end }}
{{- with $w.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- include "application.tplvalues.render" (dict "value" . "context" $root) | nindent 2 }}
{{- end }}
{{- with $w.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $w.dnsConfig }}
dnsConfig:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
