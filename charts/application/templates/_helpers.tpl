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
{{ include "application.labels.team" . }}
*/}}
{{- define "application.labels.group" -}}
team: {{ .Values.labels.group }}
{{- end -}}

{{/*
Includes global labels for this helm chart
Usage:
{{ include "application.labels.chart" . }}
*/}}
{{- define "application.labels.chart" -}}
{{ include "application.labels.group" . }}
{{ include "application.labels.team" . }}
chart: "{{ .Chart.Name }}"
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
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

