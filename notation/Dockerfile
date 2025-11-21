FROM alpine/curl:latest AS build

ARG NOTATION_VERSION=1.3.2
ARG TARGETOS
ARG TARGETARCH

RUN curl -fsSLo notation.tar.gz https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_${NOTATION_VERSION}_linux_${TARGETARCH}.tar.gz \
    && tar -xzf notation.tar.gz -C /


FROM scratch

COPY --from=build /notation /notation

CMD [ "/notation" ]
