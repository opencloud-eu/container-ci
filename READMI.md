# container-ci

A collection of Docker images used in CI/CD pipelines for the [OpenCloud](https://github.com/opencloud-eu) project. Images are built and published automatically via [Woodpecker CI](https://woodpecker-ci.org/).

## Available Images

| Image | Description |
|---|---|
| `golang/v1.25` | Go build environment |
| `nodejs` | Node.js build environment |
| `php/v8.4` | PHP build environment |
| `clamav` | ClamAV antivirus scanner |
| `buildifier` | Bazel BUILD file formatter |
| `desktop-client-build` | Desktop client build toolchain |
| `notation-wp-plugin` | Notation plugin for Woodpecker |
| `wopi-validator` | WOPI protocol validator |
| `wait-for` | Utility to wait for services to become available |

## Usage

Images are published to the container registry and can be referenced directly in your Woodpecker CI pipeline steps:

```yaml
steps:
  - name: build
    image: quay.io/opencloudeu/<image-name>:<tag>
```

## CI

Pipelines are defined in [`.woodpecker/`](.woodpecker/). Images are rebuilt automatically on push to `main`.

## License

[Apache-2.0](LICENSE)