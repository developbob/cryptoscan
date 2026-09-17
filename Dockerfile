# Build stage
ARG BUILDER_IMAGE=golang:1.21-alpine
ARG RUNTIME_IMAGE=alpine:3.19
FROM ${BUILDER_IMAGE} AS builder

ARG VERSION=dev
ARG COMMIT=none
ARG DATE=unknown

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT} -X main.date=${DATE}" \
    -o cryptoscan ./cmd/cryptoscan

# Runtime stage
FROM ${RUNTIME_IMAGE}

RUN apk --no-cache add ca-certificates git jq

WORKDIR /app

COPY --from=builder /app/cryptoscan /usr/local/bin/cryptoscan

ENTRYPOINT ["cryptoscan"]
CMD ["--help"]
