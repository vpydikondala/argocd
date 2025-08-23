{{- define "product-api.name" -}}
product-api
{{- end }}

{{- define "product-api.fullname" -}}
{{ include "product-api.name" . }}
{{- end }}
