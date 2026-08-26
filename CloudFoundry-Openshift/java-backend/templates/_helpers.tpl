
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

{{- define "java-backend.quoteIfNotString" }}
{{- $value := . -}}
{{- if not (kindOf $value | eq "string") -}}
"{{- toString $value -}}"
{{- else -}}
{{- $value -}}
{{- end -}}
{{- end -}}

{{- define "java-backend.command.parse" -}}
{{- $commandLine := . -}}
{{- $words := splitList " " $commandLine -}}
{{- $isShellCommand := false -}}

{{- range list "&&" "||" "|" ">" "<" ";" "$" -}}
{{- if contains . $commandLine -}}
{{- $isShellCommand = true -}}
{{- end -}}
{{- end -}}

{{- if $isShellCommand -}}
command:
  - "/bin/bash"
args:
  - "-c"
  - |
    {{ $commandLine }}
{{- else -}}
{{- $args := rest $words -}}
command:
  - {{ first $words | quote }}
{{ $args := rest $words -}}
{{- if $args -}}
args:
{{- range $args }}
  - {{ . | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
