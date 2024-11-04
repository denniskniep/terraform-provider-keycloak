GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)
GOOS?=linux
GOARCH?=amd64

MAKEFLAGS += --silent

VERSION=$$(git describe --tags)

build:
	CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X main.version=$(VERSION)" -o terraform-provider-keycloak_$(VERSION)

build-example: build
	mkdir -p example/.terraform/plugins/terraform.local/denniskniep/keycloak/4.0.0/$(GOOS)_$(GOARCH)
	mkdir -p example/terraform.d/plugins/terraform.local/denniskniep/keycloak/4.0.0/$(GOOS)_$(GOARCH)
	cp terraform-provider-keycloak_* example/.terraform/plugins/terraform.local/denniskniep/keycloak/4.0.0/$(GOOS)_$(GOARCH)/
	cp terraform-provider-keycloak_* example/terraform.d/plugins/terraform.local/denniskniep/keycloak/4.0.0/$(GOOS)_$(GOARCH)/

local: deps
	docker-compose up --build -d
	./scripts/wait-for-local-keycloak.sh
	./scripts/create-terraform-client.sh

deps:
	./scripts/check-deps.sh

fmt:
	gofmt -w -s $(GOFMT_FILES)

test: fmtcheck vet
	go test $(TEST)

testacc: export TF_ACC=1
testacc: export CHECKPOINT_DISABLE=1
testacc: export KEYCLOAK_CLIENT_ID=terraform
testacc: export KEYCLOAK_CLIENT_SECRET=884e0f95-0f42-4a63-9b1f-94274655669e
testacc: export KEYCLOAK_CLIENT_TIMEOUT=30
testacc: export KEYCLOAK_REALM=master
testacc: export KEYCLOAK_TEST_PASSWORD_GRANT=true
testacc: export KEYCLOAK_URL=http://localhost:8080
testacc: export KEYCLOAK_VERSION=26.0.4
testacc: fmtcheck vet
	go test -v github.com/denniskniep/terraform-provider-keycloak/keycloak
	go test -v -timeout 60m -parallel 4 github.com/denniskniep/terraform-provider-keycloak/provider $(TESTARGS)

fmtcheck:
	lineCount=$(shell gofmt -l -s $(GOFMT_FILES) | wc -l | tr -d ' ') && exit $$lineCount

vet:
	go vet ./...

user-federation-example:
	cd custom-user-federation-example && ./gradlew shadowJar
