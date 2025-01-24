{{- define "reversed-ip.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "reversed-ip.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{- define "reversed-ip.mysql.serviceName" -}}
{{ .Release.Name }}-mysql
{{- end -}}