---
name: notation
icon: https://avatars.githubusercontent.com/u/32203186
description: plugin to sign container images using https://notaryproject.dev/
author: flimmy@opencloud.eu
tags: [docker, image, container, notation, sign, signature]
containerImage: opencloudeu/notation-wp-plugin
containerImageUrl: https://hub.docker.com/r/opencloudeu/notation-wp-plugin
url: https://github.com/opencloud-eu/container-ci/tree/main/notation
---

# Overview

Woodpecker CI plugin to sign container images using [Notation](https://notaryproject.dev/).

## Features

- Provide Certificates via secret or setting
- get target digest from registry
- sign for multiple registries

## Settings

| Settings Name           | Default                       | Description                                                     |
| ----------------------- | ----------------------------- | --------------------------------------------------------------- |
| `key`                   | _none_                        | **required** the PEM-encoded private key used for the signature |
| `crt`                   | _none_                        | **required** the PEM-encoded cert-chain used for the signature  |
| `logins`                | _none_                        | **required** logins for the registries, see [logins](#logins)   |
| `target`                | _none_                        | **required** the image to sign                                  |
| `additional`            | _none_                        | additional registries to push a signature to                    |

### key and crt

The PEM-encoded private key and certificate chain used for the signature. These can and should be provided using secrets.

### logins

The login information used to pull the manifest and push the signature:

```yaml
- name: sign
  image: opencloudeu/notation-wp-plugin
  settings:
  ...
    logins:
      - registry: https://index.docker.io/v1/
        username:
          from_secret: docker_username
        password:
          from_secret: docker_password
      - registry: https://quay.io
        username:
          from_secret: quay_username
        password:
          from_secret: quay_password
```

### target

The image you want to sign. To ensure the correct image is signed, this should either be the image with its digest or a tagged image on a trusted/internal registry.

```yaml
- name: sign
  image: opencloudeu/notation-wp-plugin
  settings:
  ...
    target: registry.local/opencloudeu/notation-wp-plugin@sha256:ace246...
```

```yaml
- name: sign
  image: opencloudeu/notation-wp-plugin
  settings:
  ...
    target: registry.local/opencloudeu/notation-wp-plugin:commit-abc123...
```

### additional

Additional registries hosting this image to push a signature to:

```yaml
- name: sign
  image: opencloudeu/notation-wp-plugin
  settings:
  ...
    additional:
      - docker.io/opencloudeu/notation-wp-plugin
      - quay.io/opencloudeu/notation-wp-plugin
```

## Examples

```yaml
---
when:
  - event:
      - push
      - tag

steps:
  - name: sign
    image: opencloudeu/notation-wp-plugin
    pull: true
    settings:
      key:
        from_secret: notation_key
      crt:
        from_secret: notation_cert
      logins:
        - registry: https://index.docker.io/v1/
          username:
            from_secret: docker_username
          password:
            from_secret: docker_password
        - registry: https://quay.io
          username:
            from_secret: quay_username
          password:
            from_secret: quay_password
      target: registry.local/opencloud/notation-wp-plugin:commit-${CI_COMMIT_SHA}
      additional:
        - docker.io/opencloudeu/notation-wp-plugin
        - quay.io/opencloudeu/notation-wp-plugin
```
