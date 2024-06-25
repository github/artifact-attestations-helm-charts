# Artifact Attestations Helm Charts

This repository hosts GitHub's Helm charts used to deploy [a Kubernetes admission controller for Artifact Attestations](https://docs.github.com/en/actions/security-guides/enforcing-artifact-attestations-with-a-kubernetes-admission-controller). This admission controller allows you to enforce the provenance of artifacts deployed to your cluster by verifying their [Artifact Attestations](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds#verifying-artifact-attestations-with-the-github-cli).

The admission controller consists of:
- A Helm chart for our [temporary fork](https://github.com/github/policy-controller) of the [Sigstore Policy Controller](https://github.com/github/artifact-attestations-helm-charts/tree/main/charts/policy-controller)
- A Helm chart for deploying [GitHub's TrustRoot and a default ClusterImagePolicy](https://github.com/github/artifact-attestations-helm-charts/tree/main/charts/trust-policies)

These charts are configured to enforce that images installed on a cluster have provenance attestations generated with the
[Attest Build Provenance GitHub Action](https://github.com/actions/attest-build-provenance).

These charts are published to GitHub Container Registry (GHCR) as OCI images. Each release is attested by
the [Attest Build Provenance Action](https://github.com/actions/attest-build-provenance).

You can verify these releases with the [`gh` CLI](https://cli.github.com/manual/gh_attestation_verify):
```bash
gh attestation verify --owner github \
    oci://ghcr.io/github/artifact-attestations-helm-charts/policy-controller:v0.9.0-github3
```

For more information, see [our documentation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds) on using artifact attestations to establish build provenance and the [blog post](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/) introducing Artifact Attestations.

## Installation
### Install the Sigstore Policy Controller

You will need to install two charts. First, install the Sigstore policy controller:

```bash
helm install policy-controller --atomic \
  --create-namespace --namespace artifact-attestations \
  oci://ghcr.io/github/artifact-attestations-helm-charts/policy-controller \
  --version v0.9.0-github3
```

The `--atomic` flag will delete the installation if failure occurs.
The `--create-namespace` will create the release namespace if not present.

### Install GitHub's `TrustRoot` and a `ClusterImagePolicy`

Next, install the default GitHub policy to be used with policy controller:

```bash
helm install trust-policies --atomic \
 --namespace artifact-attestations \
 oci://ghcr.io/github/artifact-attestations-helm-charts/trust-policies \
 --version v0.4.0 \
 --set policy.enabled=true \
 --set policy.organization=MY-ORGANIZATION
```

By setting `policy.organization` to a specific organization, the policy
controller will verify the workflow that signed an image's attestation is hosted
in a repository within the specified organization.

See [here](charts/policies/values.yaml) for a complete set of modifiable
policy chart values.

Once the charts are installed, policy controller should be running on your cluster.
A namespace must be labeled with `policy.sigstore.dev/include=true` before
policy controller can enforce the trust policy for any images we try to install
on it. Label a namespace with the following:
```bash
kubectl label namespace MYNAMESPACE policy.sigstore.dev/include=true
```

## License

This project is licensed under the terms of the Apache 2.0 open source license. Please refer to [Apache 2.0](./LICENSE) for the full terms.

## Maintainers

See [CODEOWNERS](./CODEOWNERS) for a list of maintainers.

## Support

If you have any questions or issues following examples outlined in this repository,
please file an [issue](https://github.com/github/artifact-attestations-helm-charts/issues/new?template=Blank+issue) and we will assist you.

## Maintainer Documentation

### Cutting a New Release

When you are ready to cut a new release for a given Helm chart

1. Update the chart's `AppVersion` and `Version` to the appropriate values
1. Create a new tag prefixed with the targeted chart name in the format <my-chart-name>-v0.1.2, ex: `git tag -s "policy-controller-v0.9.0-github3" -m "policy-controller-v0.9.0-github3"`
1. Push the tag, ex: `git push origin "policy-controller-v0.9.0-github3"`
1. The [release workflow](.github/workflows/release.yml) will be triggered if
the chart's tag format is included in the list of tags that trigger the workflow.
The tag must follow the format `<my-chart-name>-v<semantic-version>`
