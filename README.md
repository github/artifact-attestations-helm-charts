# GitHub Helm Charts

This repository hosts the GitHub flavored [Policy Controller](https://github.com/sigstore/policy-controller) Helm charts.

The policy controller is an an admission controller built to enforce policies
on a Kubernetes cluster.

The Helm charts included in this repository are configured to enforce that
images installed on a cluster are attested by the
[Attest Build Provenance GitHub Action](https://github.com/actions/attest-build-provenance).

The charts are published to GHCR as OCI images. Each release is attested by
the [Attest Build Provenance Action](https://github.com/actions/attest-build-provenance).

You can verify these release with the `gh` CLI:
```bash
gh attestation verify \
    oci://ghcr.io/github/policy-controller-helm/policy-controller:v0.9.0-github2 \
    --owner github
```

## Installing the Charts

## Maintainer Documentation

### Cutting a New Release

When you are ready to cut a new release for a given Helm chart

1. Update the chart's `AppVersion` and `Version` to the appropriate values
1. Create a new tag prefixed with the targeted chart name in the format <my-chart-name>-v0.1.2, ex: `git tag -s "policy-controller-v0.10.0-github2" -m "policy-controller-v0.10.0-github2"`
1. Push the tag, ex: `git push origin "policy-controller-v0.10.0-github2"`
1. The [release workflow](.github/workflows/release.yml) will be triggered if 
the chart's tag format is included in the list of tags that trigger the workflow.
The tag must follow the format `<my-chart-name>-v<semantic-version>`
