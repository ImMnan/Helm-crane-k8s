
{{- define "blazemeter-crane.fullname" -}}
{{- default .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "blazemeter-crane.serviceAccountName" -}}
{{- if .Values.deploymentRbac.serviceAccount.create }}
    {{- default (include "blazemeter-crane.fullname" .) .Values.deploymentRbac.serviceAccount.name -}}
{{- else }}
    {{- default "default" .Values.deploymentRbac.serviceAccount.name -}}
{{ end }}
{{ end }}