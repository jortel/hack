# Quickstart GitOps Helm Chart

A Helm chart for generating ArgoCD Application definitions to onboard Java microservices into OpenShift GitOps.

Designed as a companion generator to [quickstart-java-service](../quickstart-java-service) in the [Konveyor](https://www.konveyor.io/) Assets Generation engine. Each chart is a standalone generator — this one produces the GitOps configuration, while `quickstart-java-service` produces the deployment manifests that ArgoCD will manage.

## Prerequisites

- Helm 3.x+
- OpenShift GitOps operator installed (or a standalone ArgoCD instance)

## Quick Start

```bash
helm template my-release . \
  --set application.name=my-service \
  --set application.assetRepository.url=https://github.com/acme/my-service-config.git \
  --set application.assetRepository.branch=main \
  --set application.assetRepository.path=/manifests \
  --set targetNamespace=my-service-prod
```

## What Gets Deployed

| Resource | Template | Default |
|---|---|---|
| ArgoCD Application | `application.yaml` | Created when `application.assetRepository.url` is provided |
| ArgoCD AppProject | `appproject.yaml` | Disabled |

## Configuration

### Required

| Parameter | Description |
|---|---|
| `application.assetRepository.url` | Git repository URL containing the deployment manifests |
| `targetNamespace` | Namespace where the application will be deployed |

### Application Metadata

Populated by the Konveyor generator addon. All fields are optional.

| Parameter | Description |
|---|---|
| `application.name` | Application name (used as the ArgoCD Application resource name) |
| `application.owner` | Application owner (added as `konveyor.io/owner` label) |
| `application.businessService` | Business vertical (added as `konveyor.io/business-service` label) |
| `application.archetypes[0]` | Application archetype (added as `konveyor.io/archetype` label) |
| `application.assetRepository.url` | Config repository URL (added as `konveyor.io/config-repository` annotation) |
| `application.assetRepository.branch` | Git branch for `targetRevision` |
| `application.assetRepository.tag` | Git tag for `targetRevision` (takes precedence over branch) |
| `application.assetRepository.path` | Path within the repository to the manifests |

### ArgoCD Settings

| Parameter | Description | Default |
|---|---|---|
| `argocd.namespace` | Namespace where the Application CR is created | `openshift-gitops` |
| `argocd.project` | ArgoCD project to assign the application to | `default` |
| `argocd.destinationServer` | Target cluster URL | `https://kubernetes.default.svc` |
| `argocd.syncPolicy.automated.prune` | Delete resources removed from git | `true` |
| `argocd.syncPolicy.automated.selfHeal` | Revert manual changes to match git | `true` |
| `argocd.syncPolicy.syncOptions` | Sync options list | `[CreateNamespace=true]` |

#### Switching to Manual Sync

To disable automated sync, set `automated` to null in your values file:

```yaml
argocd:
  syncPolicy:
    automated:
    syncOptions:
      - CreateNamespace=true
```

### AppProject (Optional)

| Parameter | Description | Default |
|---|---|---|
| `appProject.enabled` | Create a dedicated ArgoCD AppProject | `false` |
| `appProject.additionalSourceRepos` | Extra source repos beyond the config repository | `[]` |
| `appProject.additionalDestinations` | Extra destination namespaces beyond `targetNamespace` | `[]` |

When enabled, the AppProject is scoped to the application's config repository and target namespace. The Application CR automatically references the project.

### Naming

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override the chart name portion of resource names | `""` |
| `fullnameOverride` | Override the full resource name entirely | `""` |

Resource naming follows the same precedence as `quickstart-java-service`: `fullnameOverride` > `application.name` > release-name-based default.

## Konveyor Integration

This chart is designed to be used as a Konveyor Generator. The generator addon builds a `values.yaml` from the canonical configuration dictionary and passes it to `helm template`. The `application` block maps directly to the Konveyor application profile.

### Example Konveyor Values

```yaml
application:
  name: my-service
  owner: jsmith
  businessService: payments
  archetypes:
    - spring-boot-api
  assetRepository:
    kind: git
    url: https://github.com/acme/my-service-config.git
    branch: main
    tag: ""
    path: /manifests

targetNamespace: my-service-prod
```

### Source Revision Logic

The chart resolves `spec.source.targetRevision` using: `tag` (if set) > `branch` (if set) > `HEAD` (fallback).
