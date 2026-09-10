{{/*
Chart name, truncated to 63 characters.
*/}}
{{- define "quickstart-gitops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "quickstart-gitops.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.application }}
{{- .Values.application.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label value (name + version).
*/}}
{{- define "quickstart-gitops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Standard labels.
*/}}
{{- define "quickstart-gitops.labels" -}}
helm.sh/chart: {{ include "quickstart-gitops.chart" . }}
app.kubernetes.io/name: {{ include "quickstart-gitops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- include "quickstart-gitops.konveyorLabels" . }}
{{- end }}

{{/*
Konveyor metadata labels (conditional).
*/}}
{{- define "quickstart-gitops.konveyorLabels" -}}
{{- if .Values.application }}
{{- if .Values.application.owner }}
konveyor.io/owner: {{ .Values.application.owner | quote }}
{{- end }}
{{- if .Values.application.businessService }}
konveyor.io/business-service: {{ .Values.application.businessService | quote }}
{{- end }}
{{- if .Values.application.archetypes }}
konveyor.io/archetype: {{ first .Values.application.archetypes | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Konveyor metadata annotations (conditional).
*/}}
{{- define "quickstart-gitops.konveyorAnnotations" -}}
{{- if .Values.application }}
{{- if .Values.application.assetRepository }}
{{- if .Values.application.assetRepository.url }}
konveyor.io/config-repository: {{ .Values.application.assetRepository.url | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
ArgoCD Application source targetRevision.
Uses tag if set, otherwise branch, otherwise falls back to HEAD.
*/}}
{{- define "quickstart-gitops.targetRevision" -}}
{{- if and .Values.application .Values.application.assetRepository }}
{{- if .Values.application.assetRepository.tag }}
{{- .Values.application.assetRepository.tag }}
{{- else if .Values.application.assetRepository.branch }}
{{- .Values.application.assetRepository.branch }}
{{- else }}
{{- "HEAD" }}
{{- end }}
{{- else }}
{{- "HEAD" }}
{{- end }}
{{- end }}

{{/*
ArgoCD Application source path.
Defaults to "/" if not set.
*/}}
{{- define "quickstart-gitops.sourcePath" -}}
{{- if and .Values.application .Values.application.assetRepository .Values.application.assetRepository.path }}
{{- .Values.application.assetRepository.path }}
{{- else }}
{{- "/" }}
{{- end }}
{{- end }}
