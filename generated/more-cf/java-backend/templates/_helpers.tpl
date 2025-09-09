
{{/*
Create the name of the service account to use
*/}}
{{- define "java-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default .Values.manifest.name .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "java-backend.registry" -}}image-registry.openshift-image-registry.svc:5000/{{ .Release.Namespace }}/{{- end -}}

{{/*
Returns the executable name from a command string.
Example: "./tr-server" -> "tr-server"
Example: "bundle exec run-authenticator" -> "run-authenticator"
*/}}
{{- define "java-backend.executableName" -}}
{{- $command := . | trim -}}
{{- $parts := splitList " " $command -}}
{{- $lastPart := last $parts -}}
{{- if regexMatch `\..*` $lastPart -}}
{{- regexFind `[^/]+$` $lastPart -}}
{{- else -}}
{{- $lastPart -}}
{{- end -}}
{{- end -}}
