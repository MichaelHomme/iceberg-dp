{{- define "apache-platform.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "apache-platform.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "apache-platform.labels" -}}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/part-of: apache-platform
platform.frigg/component: data-platform
{{- end -}}
