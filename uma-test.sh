#!/bin/bash

DISTRIBUTION=$1

# Init
HOST=$2
OP_HOST=$3
OXD_HOST='localhost'
KONG_PROXY_HOST=$2
KONG_ADMIN_HOST='localhost'

# Create OP Client for Consumer
OP_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/register-site  -H "Content-Type: application/json" -d  '{"client_name":"test_oauth_pep","op_host":"https://'$OP_HOST'","authorization_redirect_uri": "https://client.example.com/cb", "grant_types":["client_credentials"]}'`

CONSUMER_OXD_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".oxd_id"`
CONSUMER_CLIENT_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".client_id"`
CONSUMER_CLIENT_SECRET=`echo $OP_CLIENT_RESPONSE | jq -r ".client_secret"`
echo "OXD_ID " .. $CONSUMER_OXD_ID
echo "CLIENT_ID " .. $CONSUMER_CLIENT_ID
echo "CLIENT_SECRET " .. $CONSUMER_CLIENT_SECRET

# Create kong consumer
CONSUMER_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/consumers/  -H 'Content-Type: application/json'  -d '{"username":"cons_jsonplaceholder","custom_id":"'$CONSUMER_CLIENT_ID'"}'`

CONSUMER_ID=`echo $CONSUMER_RESPONSE | jq -r ".id"`
echo "CONSUMER_ID " .. $CONSUMER_ID

echo "Create another service in kong"

SERVICE_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/services/  -H 'Content-Type: application/json'  -d '{"name":"jsonplaceholder2","url":"https://jsonplaceholder.typicode.com"}'`

SERVICE_ID=`echo $SERVICE_RESPONSE | jq -r ".id"`
echo "SERVICE_ID " .. $SERVICE_ID

ROUTE_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/routes/ -H 'Content-Type: application/json' -d '{"hosts": ["jsonplaceholder2.typicode.com"],"service": {"id": "'$SERVICE_ID'"}}'`

ROUTE_ID=`echo $ROUTE_RESPONSE | jq -r ".id"`
echo "ROUTE_ID " .. $ROUTE_ID

# Create OP Client for UMA_PEP

OP_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/register-site  -H "Content-Type: application/json" -d  '{"client_name":"test_uma_pep", "op_host":"https://'$OP_HOST'", "authorization_redirect_uri": "https://client.example.com/cb", "scope": ["openid", "oxd", "uma_protection"], "grant_types":["client_credentials"]}'`

OXD_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".oxd_id"`
CLIENT_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".client_id"`
CLIENT_SECRET=`echo $OP_CLIENT_RESPONSE | jq -r ".client_secret"`
echo "OXD_ID " .. $OXD_ID
echo "CLIENT_ID " .. $CLIENT_ID
echo "CLIENT_SECRET " .. $CLIENT_SECRET

# Register resources using OXD
# GET PROTECTION TOKEN
RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/get-client-token -H "Content-Type: application/json" -d '{"client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'","op_host":"'$OP_HOST'", "scope":["openid", "oxd", "uma_protection"]}'`

TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "PROTECTION TOKEN " .. $TOKEN

RS_PROTECT_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/uma-rs-protect -H "Authorization: Bearer $TOKEN"  -H "Content-Type: application/json" -d  '{"oxd_id":"'$OXD_ID'","resources":[{"path":"/posts","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["admin","employee"]}}]},{"path":"/comments","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0}]},"data":["admin"]}}]}]}'`

echo "RS_PROTECT_CLIENT_RESPONSE " .. $RS_PROTECT_CLIENT_RESPONSE


# Config plugin
UMA_PLUGIN_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/plugins/  -H 'Content-Type: application/json'  -d '{"name":"gluu-uma-pep","config":{"oxd_url":"https://'$OXD_HOST':8443","op_url":"https://'$OP_HOST'","oxd_id":"'$OXD_ID'","client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'","uma_scope_expression":[{"path":"/posts","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["admin","employee"]}}]},{"path":"/comments","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0}]},"data":["admin"]}}]}],"ignore_scope":false,"deny_by_default":true,"hide_credentials":false},"service_id":"'$SERVICE_ID'"}'`

UMA_PLUGIN_ID=`echo $UMA_PLUGIN_RESPONSE | jq -r ".id"`
echo "UMA_PLUGIN_ID " .. $UMA_PLUGIN_ID

############################################
# UMA Auth - Request to first path `/posts/1`
############################################
TICKET=`curl -i -sS -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H 'Host: jsonplaceholder2.typicode.com' | sed -n 's/.*ticket="//p'`
TICKET="${TICKET%??}"
echo "Ticket for path /posts/1 is " .. $TICKET

RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/get-client-token -H "Content-Type: application/json" -d '{"client_id":"'$CONSUMER_CLIENT_ID'","client_secret":"'$CONSUMER_CLIENT_SECRET'","op_host":"'$OP_HOST'", "scope":["openid", "oxd", "uma_protection"]}'`

TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "PROTECTION Token " .. $TOKEN

RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/uma-rp-get-rpt -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"oxd_id":"'$CONSUMER_OXD_ID'","ticket":"'$TICKET'"}'`

echo $RESPONSE
RPT_TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "RPT Token for path /posts/1 is  " .. $RPT_TOKEN

curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'

CHECK_STATUS=`curl -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com' --write-out "%{http_code}\n" --silent --output /dev/null http://$KONG_PROXY_HOST:8000/posts/1`

if [ "$CHECK_STATUS" != "200" ]; then
    echo "UMA PEP security fail for path /posts/1"
    exit 1
fi


############################################
# UMA Auth - Request to first path `/comments/1`
############################################
TICKET=`curl -i -sS -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H 'Host: jsonplaceholder2.typicode.com' | sed -n 's/.*ticket="//p'`
TICKET="${TICKET%??}"
echo "Ticket for path /comments/1 is " .. $TICKET

RESPONSE=`curl -k -X POST https://$OXD_HOST:8443/uma-rp-get-rpt -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"oxd_id":"'$CONSUMER_OXD_ID'","ticket":"'$TICKET'","rpt":"'$RPT_TOKEN'"}'`

echo $RESPONSE
RPT_TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "RPT Token for path /comments/1/ is " .. $RPT_TOKEN

curl -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'

CHECK_STATUS=`curl -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com' --write-out "%{http_code}\n" --silent --output /dev/null http://$KONG_PROXY_HOST:8000/comments/1`

if [ "$CHECK_STATUS" != "200" ]; then
    echo "UMA PEP security fail for path /comments/1"
    exit 1
fi

############################################ Second time post calling
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'

CHECK_STATUS=`curl -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com' --write-out "%{http_code}\n" --silent --output /dev/null http://$KONG_PROXY_HOST:8000/posts/1`

if [ "$CHECK_STATUS" != "200" ]; then
    echo "UMA PEP security fail for path /posts/1 second time"
    exit 1
fi

################################################## Seconf time comment calling
curl -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/comments/1 -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'

CHECK_STATUS=`curl -H "Authorization: Bearer $RPT_TOKEN"  -H 'Host: jsonplaceholder2.typicode.com' --write-out "%{http_code}\n" --silent --output /dev/null http://$KONG_PROXY_HOST:8000/comments/1`

if [ "$CHECK_STATUS" != "200" ]; then
    echo "UMA PEP security fail for path /comments/1 second time"
    exit 1
fi
