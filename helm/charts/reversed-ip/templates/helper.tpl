{{- define "reversed-ip.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "reversed-ip.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}
