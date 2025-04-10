# Artifact Attestations Helm Charts

This repository hosts GitHub's Helm charts for deploying [a Kubernetes admission controller for Artifact Attestations](https://docs.github.com/en/actions/security-guides/enforcing-artifact-attestations-with-a-kubernetes-admission-controller). This admission controller allows you to enforce the provenance of artifacts deployed to your cluster by verifying their [Artifact Attestations](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds#verifying-artifact-attestations-with-the-github-cli).

The admission controller consists of:
- The [`policy-controller` chart](https://github.com/github/artifact-attestations-helm-charts/tree/main/charts/policy-controller), which is used to deploy [our temporary fork](https://github.com/github/policy-controller) of the [Sigstore Policy Controller](https://github.com/sigstore/policy-controller)
- The [`trust-policies` chart](https://github.com/github/artifact-attestations-helm-charts/tree/main/charts/trust-policies), which is used to deploy GitHub's `TrustRoot` and a default `ClusterImagePolicy`. This policy ensures that images installed on a cluster must have provenance attestations generated with the [Attest Build Provenance GitHub Action](https://github.com/actions/attest-build-provenance).

These charts are published to GitHub Container Registry (GHCR) as OCI images. Every release is attested with
the [Attest Build Provenance Action](https://github.com/github/artifact-attestations-helm-charts/blob/a50f0ad3880a562892156ab8f4ed01a349807bb3/.github/workflows/release.yml#L50).

You can verify these releases using the [`gh` CLI](https://cli.github.com/manual/gh_attestation_verify):
```bash
gh attestation verify --owner github \
    oci://ghcr.io/github/artifact-attestations-helm-charts/policy-controller:v0.12.0-github12
```

For more information, see [our documentation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds) on using artifact attestations to establish build provenance and [our blog post](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/) introducing Artifact Attestations.

## Installation
### 1. Install the Sigstore Policy Controller

You will need to install two charts. First, install the Sigstore policy controller:

```bash
helm install policy-controller --atomic \
  --create-namespace --namespace artifact-attestations \
  oci://ghcr.io/github/artifact-attestations-helm-charts/policy-controller \
  --version v0.12.0-github12
```

The `--atomic` flag will delete the installation if failure occurs.
The `--create-namespace` will create the release namespace if not present.

### 2. Install GitHub's `TrustRoot` and a `ClusterImagePolicy`

Next, install the GitHub `TrustRoot` and our default `ClusterImagePolicy`:

```bash
helm install trust-policies --atomic \
 --namespace artifact-attestations \
 oci://ghcr.io/github/artifact-attestations-helm-charts/trust-policies \
 --version v0.6.2 \
 --set policy.enabled=true \
 --set policy.organization=MY-ORGANIZATION
```

By setting `policy.organization` to a specific organization, the Sigstore policy
controller will verify that the workflow that signed an image's attestation is hosted
in a repository owned by the specified organization `MY-ORGANIZATION`

See the [`trust-policies` values.yaml file](charts/trust-policies/values.yaml) for the complete set of
`ClusterImagePolicy` values that can be customized.

### 3. Enable the policy in your namespace

Now that the `ClusterImagePolicy` has been installed, we must enable it. The policy will not be enforced until you specify which namespaces it should apply to.

Each namespace in your cluster can independently enforce policies. To enable enforcement in a namespace, you can add the following label to the namespace:

```yaml
metadata:
  labels:
    policy.sigstore.dev/include: true
```
Alternatively, you may run:

```bash
kubectl label namespace MYNAMESPACE policy.sigstore.dev/include=true
```

See GitHub's documentation on [Enforcing artifact attestations with a Kubernetes admission controller](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/enforcing-artifact-attestations-with-a-kubernetes-admission-controller) for more information.

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
1. Create a new tag prefixed with the targeted chart name in the format <my-chart-name>-v0.1.2, ex: `git tag -s "policy-controller-v0.12.0-github12" -m "policy-controller-v0.12.0-github12"`
1. Push the tag, ex: `git push origin "policy-controller-v0.12.0-github12"`
1. The [release workflow](.github/workflows/release.yml) will be triggered if
the chart's tag format is included in the list of tags that trigger the workflow.
The tag must follow the format `<my-chart-name>-v<semantic-version>`
