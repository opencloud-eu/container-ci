FROM golang:alpine AS build

#ARG NOTATION_VERSION=1.3.2
ARG TARGETOS
ARG TARGETARCH

RUN apk add git make

RUN git clone https://github.com/notaryproject/notation.git \
    && cd notation \
    && go get -u ./... \
    && go mod tidy \
    && make build \
    && mv bin/notation /notation


# FROM alpine/curl:latest AS build

# ARG NOTATION_VERSION=1.3.2
# ARG TARGETOS
# ARG TARGETARCH

# RUN curl -fsSLo notation.tar.gz https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_${NOTATION_VERSION}_linux_${TARGETARCH}.tar.gz \
#     && tar -xzf notation.tar.gz -C /


FROM alpine:latest

COPY --from=build /notation /bin/notation
RUN mkdir -p /root/.config/notation/localkeys

CMD [ "/bin/notation" ]
