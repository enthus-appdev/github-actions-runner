# github-actions-runner

[![Docker](https://github.com/enthus-appdev/github-actions-runner/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/enthus-appdev/github-actions-runner/actions/workflows/docker-publish.yml)
[![License: MIT](https://img.shields.io/github/license/enthus-appdev/github-actions-runner)](LICENSE)

A self-hosted [GitHub Actions runner](https://docs.github.com/en/actions/hosting-your-own-runners) container image, built on top of the official [`ghcr.io/actions/actions-runner`](https://github.com/actions/runner/pkgs/container/actions-runner) image with a handful of everyday CLI tools preinstalled.

The upstream runner image is intentionally minimal and does not ship `curl`, `wget`, or `rsync` — tools most real-world CI workflows expect to just be there. This image adds them so workflows don't have to `apt install` them on every run.

It is a drop-in replacement for the upstream image: anywhere `ghcr.io/actions/actions-runner` works, this image works.

## What's included

Based on [`ghcr.io/actions/actions-runner`](https://github.com/actions/runner), with the following additional packages installed via `apt`:

- `curl` — HTTP client
- `wget` — HTTP/FTP downloader
- `rsync` — fast file transfer and sync

See [`Dockerfile`](Dockerfile) for the exact build definition.

## Image

The image is published to GitHub Container Registry:

```
ghcr.io/enthus-appdev/github-actions-runner
```

Available tags:

| Tag       | Description                                                                  |
| --------- | ---------------------------------------------------------------------------- |
| `main`    | Latest build from the `main` branch. Updated on every push.                  |
| `nightly` | Latest scheduled rebuild. Updated daily to pick up upstream base-image fixes.|

For reproducible deployments, pin to an image digest (`@sha256:...`) rather than a mutable tag.

Pull it with:

```sh
docker pull ghcr.io/enthus-appdev/github-actions-runner:main
```

The package page on GHCR: <https://github.com/enthus-appdev/github-actions-runner/pkgs/container/github-actions-runner>

## Verifying the image

Every published image is signed with [cosign](https://github.com/sigstore/cosign) using [keyless signing](https://docs.sigstore.dev/cosign/signing/overview/) against the [sigstore](https://www.sigstore.dev/) public-good instance. The signing certificate is issued by Fulcio, bound to this repository's GitHub Actions OIDC identity, and logged to the Rekor transparency log.

You can verify an image with:

```sh
cosign verify \
  --certificate-identity-regexp 'https://github.com/enthus-appdev/github-actions-runner/\.github/workflows/docker-publish\.yml@.*' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  ghcr.io/enthus-appdev/github-actions-runner:main
```

A successful verification proves the image was built from this repository's workflow and has not been tampered with since.

## Usage

Because this image is a drop-in replacement for the upstream actions runner image, you can use it with any deployment method that supports `ghcr.io/actions/actions-runner`.

### With Actions Runner Controller (Kubernetes)

If you run runners on Kubernetes via [Actions Runner Controller](https://github.com/actions/actions-runner-controller), reference the image from your `AutoscalingRunnerSet` (or the legacy `RunnerDeployment`):

```yaml
apiVersion: actions.github.com/v1alpha1
kind: AutoscalingRunnerSet
metadata:
  name: my-runners
spec:
  template:
    spec:
      containers:
        - name: runner
          image: ghcr.io/enthus-appdev/github-actions-runner:main
```

See the [ARC quickstart](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller) for the full installation guide.

### With Docker directly

Since this image inherits the upstream entrypoint, registering a runner works the same way as with the upstream image. Refer to the [upstream runner documentation](https://github.com/actions/runner/blob/main/docs/automate.md) for the current registration flow.

## Build and release

The image is built and published by the [`docker-publish.yml`](.github/workflows/docker-publish.yml) workflow, which runs:

- On every push to `main`
- On a daily schedule (`33 10 * * *` UTC) — so upstream base-image and package updates get picked up even when the Dockerfile itself hasn't changed

Each run:

1. Builds the image with Docker Buildx (with GitHub Actions cache)
2. Pushes it to GHCR
3. Signs the resulting digest with cosign (keyless)

Base-image versions and third-party action digests are kept up to date by [Dependabot](.github/dependabot.yml), which opens PRs daily.

## Customizing / forking

If you need additional tools, fork the repository, edit the [`Dockerfile`](Dockerfile), and let the workflow rebuild on your fork. Only `apt`-installable packages should be added here — anything heavier (language toolchains, cloud CLIs, build-specific dependencies) is usually better installed per-job via `setup-*` actions, to keep the base image small and the cache hot.

## Contributing

Issues and pull requests are welcome. For anything larger than a dependency bump or a package addition, please open an issue first to discuss the change.

## License

The contents of this repository are licensed under the [MIT License](LICENSE) © enthus GmbH.

The built image is derived from [`ghcr.io/actions/actions-runner`](https://github.com/actions/runner), which is distributed by GitHub under its [own license](https://github.com/actions/runner/blob/main/LICENSE).
