# GitHub Artifact Attestations Policy Controller Helm Charts

This repository hosts the GitHub's [Policy Controller](https://github.com/github/policy-controller) Helm charts.

The policy controller is an admission controller built to enforce policies
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

## Background 

See the [official documentation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds) on
using artifact attestations to establish build provenance and
the [blog post](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/) introducing Artifact Attestations.

## Installing the Charts

You will need to install two charts. First, install the policy controller:

```bash
helm install policy-controller \
    ghcr.io/github/policy-controller-helm/policy-controller \
    --create-namespace --atomic --version v0.9.0-github2
```

The `--create-namespace` will create the release namespace if not present.
The `--atomic` flag will delete the installation if failure occurs. 

Next, install the default GitHub policy to be used with policy controller:

```bash
helm install github-artifact-attestation-policy \
    ghcr.io/github/policy-controller-helm/policies \ 
    --set policy.enabled=true \
    --set policy.organization=MYORG
```

By setting `policy.organization` to a specific organization, the policy
controller will verify the workflow that signed an image's attestation is hosted
in a repository within the specified organization.

See [here](charts/policies/values.yaml) for a complete set of modifiable 
policy chart values.

## License 

This project is licensed under the terms of the Apache 2.0 open source license. Please refer to [Apache 2.0](./LICENSE) for the full terms.

## Maintainers 

See [CODEOWNERS](./CODEOWNERS) for a list of maintainers.

## Support

If you have any questions or issues following examples outlined in this repository,
please file an [issue](https://github.com/github/policy-controller-helm/issues/new?template=Blank+issue) and we will assist you.

## Maintainer Documentation

### Cutting a New Release

When you are ready to cut a new release for a given Helm chart

1. Update the chart's `AppVersion` and `Version` to the appropriate values
1. Create a new tag prefixed with the targeted chart name in the format <my-chart-name>-v0.1.2, ex: `git tag -s "policy-controller-v0.10.0-github2" -m "policy-controller-v0.10.0-github2"`
1. Push the tag, ex: `git push origin "policy-controller-v0.10.0-github2"`
1. The [release workflow](.github/workflows/release.yml) will be triggered if 
the chart's tag format is included in the list of tags that trigger the workflow.
The tag must follow the format `<my-chart-name>-v<semantic-version>`
