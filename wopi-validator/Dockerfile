FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine@sha256:1b84f59aae0560125713a8805a6afb2f84097e279b6aa246c3005daeb0d773cc as build

ENV WOPI_VALIDATOR_VERSION=afe0e5fa1ef2e43f76265166e63c4b35eb391892

WORKDIR /
ADD https://github.com/microsoft/wopi-validator-core/archive/$WOPI_VALIDATOR_VERSION.tar.gz /wopi-validator-core.tar.gz
RUN tar xvfz wopi-validator-core.tar.gz --directory /
RUN mv /wopi-validator-core-$WOPI_VALIDATOR_VERSION /app

WORKDIR /app/
RUN dotnet build -c Release
RUN find /app/src/WopiValidator/bin/Release

FROM mcr.microsoft.com/dotnet/runtime:6.0-alpine@sha256:f971a195d9a159980f90442a9086efc51fe2c127e1ff331ace01e523a9875c33

LABEL maintainer="openCloud Team team@opencloud.eu" \
  org.opencontainers.image.title="wopi-validator Image" \
  org.opencontainers.image.vendor="openCloud GmbH" \
  org.opencontainers.image.authors="openCloud GmbH" \
  org.opencontainers.image.description="Custom wopi-validator image for CI" \
  org.opencontainers.image.documentation="https://github.com/opencloud-eu/container-ci" \
  org.opencontainers.image.url="https://github.com/opencloud-eu/container-ci" \
  org.opencontainers.image.source="https://github.com/opencloud-eu/container-ci"

RUN apk add --no-cache curl jq
WORKDIR /app/
COPY --from=build /app/LICENSE /app/LICENSE
COPY --from=build /app/src/WopiValidator/bin/Release/net6.0 /app

ENTRYPOINT [ "/app/Microsoft.Office.WopiValidator"]
