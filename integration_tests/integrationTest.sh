#!/bin/bash
set -e

TEST_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3MDYxMTg4MTAsImV4cCI6MTczNzY1NDgxMCwiYXVkIjoid3d3LmV4YW1wbGUuY29tIiwic3ViIjoianJvY2tldEBleGFtcGxlLmNvbSIsIkdpdmVuTmFtZSI6IkpvaG5ueSIsIlN1cm5hbWUiOiJSb2NrZXQiLCJFbWFpbCI6Impyb2NrZXRAZXhhbXBsZS5jb20iLCJSb2xlIjpbImRhdGEucmVhZCIsImRhdGEud3JpdGUiXX0.FwkQbYt6Z0r634zmwlyb-5EDo0nk59b41LVPjBi_egY
TEST_INFORMATION="TEST_$(date +%s%N)"

cd ../infrastructure/
echo "Initializing terraform to get API URL"
terraform init
terraform workspace select dev
API_URL=$(terraform output -raw apigw_url)

echo "Using API URL: $API_URL"

echo "Posting Data"
POST_RETURN_STATUS=$(curl -X POST \
    --location "$API_URL/data" \
    --header "Authorization: Bearer $TEST_TOKEN" \
    --header 'Content-Type: application/json' \
    --data "{
        \"informationOne\": \"$TEST_INFORMATION\",
        \"informationTwo\": \"bbb24\"
    }" \
    --write-out "%{http_code}"\
    --output ".\test_output_files\postResult" \
    --silent)

if ! [[ $POST_RETURN_STATUS -eq 201 ]] ; then
    echo "Error during POST DATA"
    cat ".\test_output_files\postResult"
    exit -1
fi

echo "Waiting 1 second"
sleep 1

echo "Getting data"
GET_RETURN_STATUS=$(curl -X GET \
    --location "$API_URL/data" \
    --header "Authorization: Bearer $TEST_TOKEN" \
    --write-out "%{http_code}" \
    --output ".\test_output_files\getResult" \
    --silent)

if ! [[ $GET_RETURN_STATUS -eq 200 ]] ; then
    echo "Error during GET DATA"
    cat ".\test_output_files\getResult"
    exit -1
fi

TEST_RESULT=$(cat ".\test_output_files\getResult" | jq '.[] | select(.InformationOne == "'$TEST_INFORMATION'")')

if [[ -z "$TEST_RESULT" ]]; then
    echo "ERROR: The posted value didn't returned in the GET request"
    exit -1
else
    echo "SUCCESS: The posted value returned in the GET request"
fi