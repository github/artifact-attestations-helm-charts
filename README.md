# GitHub Sigstore Policy Controller Helm Charts

This repository hosts the GitHub's [Policy Controller](https://github.com/github/policy-controller) Helm charts.

The policy controller is an an admission controller built to enforce policies
on a Kubernetes cluster.

The Helm charts included in this repository are configured to enforce that
images installed on a cluster have provenance attestations generated with the
[Attest Build Provenance GitHub Action](https://github.com/actions/attest-build-provenance).

The charts are published to GitHub Container Registry (GHCR) as OCI images. Each release is attested by
the [Attest Build Provenance Action](https://github.com/actions/attest-build-provenance).

You can verify these release with the `gh` CLI:
```bash
gh attestation verify \
    oci://ghcr.io/github/policy-controller-helm/policy-controller:v0.9.0-github2 \
    --owner github
```

## Installing the Charts

You will need to install two charts. First, install the policy controller:

```bash
helm install policy-controller \
    ghcr.io/github/policy-controller-helm/policy-controller \
    --create-namespace --atomic --version v0.9.0-github2
```

The `--create-namespace` will create the release namespace if not present.
The `--atmoic` flag will delete the installation if failure occurs. 

Next, install the default GitHub policy to be used with policy controller:

```bash
helm install policy-controller-policies \
    ghcr.io/github/policy-controller-helm/policies --set policy.enabled=true \
    --set policy.organization=MYORG
```

By setting `policy.organization` to a specific organization, the policy
controller will verify the workflow that signed an image's attestation is hosted
in a repository within the specified organization.

See [here](charts/policies/values.yaml) for a complete set of modifiable 
policy chart values.

## Maintainer Documentation

### Cutting a New Release

When you are ready to cut a new release for a given Helm chart

1. Update the chart's `AppVersion` and `Version` to the appropriate values
1. Create a new tag prefixed with the targeted chart name in the format <my-chart-name>-v0.1.2, ex: `git tag -s "policy-controller-v0.10.0-github2" -m "policy-controller-v0.10.0-github2"`
1. Push the tag, ex: `git push origin "policy-controller-v0.10.0-github2"`
1. The [release workflow](.github/workflows/release.yml) will be triggered if 
the chart's tag format is included in the list of tags that trigger the workflow.
The tag must follow the format `<my-chart-name>-v<semantic-version>`
