# GitHub Helm Charts

This repository hosts GitHub owned helm charts.
These charts are published to GHCR as OCI images. Each chart
release is attested by the [Attest Build Provenance Action](https://github.com/actions/attest-build-provenance).

## Cutting a new release

When you are ready to cut a new release for a given Helm chart

1. Update the chart's `AppVersion` and `Version` to the appropriate values
1. Create a new tag prefixed with the targeted chart name in the format <my-chart-name>-v0.1.2, ex: `git tag -s "policy-controller-v0.10.0-github2" -m "policy-controller-v0.10.0-github2"`
1. Push the tag, ex: `git push origin "policy-controller-v0.10.0-github2"`
1. The [release workflow](.github/workflows/release.yml) will be triggered if 
the chart's tag format is included in the list of tags that trigger the workflow.
The tag must follow the format `<my-chart-name>-v<semantic-version>`
