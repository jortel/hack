{{/*
Chart name, truncated to 63 characters.
*/}}
{{- define "quickstart-pipelines.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "quickstart-pipelines.fullname" -}}
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
{{- define "quickstart-pipelines.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Standard labels.
*/}}
{{- define "quickstart-pipelines.labels" -}}
helm.sh/chart: {{ include "quickstart-pipelines.chart" . }}
app.kubernetes.io/name: {{ include "quickstart-pipelines.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- include "quickstart-pipelines.konveyorLabels" . }}
{{- end }}

{{/*
Konveyor metadata labels (conditional).
*/}}
{{- define "quickstart-pipelines.konveyorLabels" -}}
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
Resolved image name: pipeline.imageName > application.name > fullname.
*/}}
{{- define "quickstart-pipelines.imageName" -}}
{{- if .Values.pipeline.imageName }}
{{- .Values.pipeline.imageName }}
{{- else }}
{{- include "quickstart-pipelines.fullname" . }}
{{- end }}
{{- end }}

{{/*
Full image reference: registry/namespace/name.
The namespace portion is left as a pipeline param (uses the target namespace at runtime).
*/}}
{{- define "quickstart-pipelines.imageBase" -}}
{{- printf "%s/$(params.NAMESPACE)/%s" .Values.pipeline.imageRegistry (include "quickstart-pipelines.imageName" .) }}
{{- end }}

{{/*
Git repo URL from application.repository.
*/}}
{{- define "quickstart-pipelines.gitRepoURL" -}}
{{- if and .Values.application .Values.application.repository .Values.application.repository.url }}
{{- .Values.application.repository.url }}
{{- end }}
{{- end }}

{{/*
Git revision from application.repository (tag > branch > main).
*/}}
{{- define "quickstart-pipelines.gitRevision" -}}
{{- if and .Values.application .Values.application.repository }}
{{- if .Values.application.repository.tag }}
{{- .Values.application.repository.tag }}
{{- else if .Values.application.repository.branch }}
{{- .Values.application.repository.branch }}
{{- else }}
{{- "main" }}
{{- end }}
{{- else }}
{{- "main" }}
{{- end }}
{{- end }}

{{/*
Whether the pipeline needs the config-source workspace.
True when using Buildah (Dockerfile lives in config repo) or when updateConfigRepo is enabled.
*/}}
{{- define "quickstart-pipelines.needsConfigWorkspace" -}}
{{- if or (eq .Values.pipeline.buildStrategy "buildah") .Values.pipeline.updateConfigRepo }}
{{- true }}
{{- end }}
{{- end }}

{{/*
Config repo URL from application.assetRepository.
*/}}
{{- define "quickstart-pipelines.configRepoURL" -}}
{{- if and .Values.application .Values.application.assetRepository .Values.application.assetRepository.url }}
{{- .Values.application.assetRepository.url }}
{{- end }}
{{- end }}

{{/*
Config repo branch from application.assetRepository (branch > main).
*/}}
{{- define "quickstart-pipelines.configRepoBranch" -}}
{{- if and .Values.application .Values.application.assetRepository }}
{{- if .Values.application.assetRepository.branch }}
{{- .Values.application.assetRepository.branch }}
{{- else }}
{{- "main" }}
{{- end }}
{{- else }}
{{- "main" }}
{{- end }}
{{- end }}
