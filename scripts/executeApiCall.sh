#!/usr/bin/env bash

KEYCLOAK_URL="http://localhost:8080"
KEYCLOAK_CLIENT_ID="terraform"
KEYCLOAK_CLIENT_SECRET="884e0f95-0f42-4a63-9b1f-94274655669e"
accessToken=$(
    curl -s --fail \
		-d "client_id=${KEYCLOAK_CLIENT_ID}" \
		-d "client_secret=${KEYCLOAK_CLIENT_SECRET}" \
        -d "grant_type=client_credentials" \
        "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
        | jq -r '.access_token'
)

function get() {
    curl  \
        -H "Authorization: Bearer ${accessToken}" \
        -H "Content-Type: application/json" \
        "${KEYCLOAK_URL}/admin${1}"
}

function put() {
    curl --fail \
        -X PUT \
        -H "Authorization: bearer ${accessToken}" \
        -H "Content-Type: application/json" \
        -d "${2}" \
        "${KEYCLOAK_URL}/admin${1}"
}

#get /realms/master

# usersProfile=$(jq -n "{}")
#put "/realms/tf-acc-5893505837518950807/users/profile" "${usersProfile}"
