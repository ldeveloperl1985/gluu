import cgi

gg_admin_url = "http://gluu.local.org:8001"
gg_proxy_url = "http://gluu.local.org:8000"
oxd_host = "https://gluu.local.org:8553"
ce_url = "https://gluu.local.org"
api_path = "posts/1"

host_with_claims = "gathering.example.com"
host_without_claims = "non-gathering.example.com"

client_oxd_id = "91b14554-17ac-4cf4-917d-f1b27e95902a"
client_id = "@!FBA4.9EDD.24E7.909F!0001!64E0.493A!0008!BE4C.B4F6.E5CC.DB74"
client_secret = "1b3e24c2-5472-4c26-a33f-b0b1c0c2b1c3"

claims_redirect_url = "https://demo.gluu.org:8080/cgi-bin/demo-client.cgi"


def is_ticket_in_url():
    arguments = cgi.FieldStorage()
    return 'ticket' in arguments


def is_claim_in_url():
    arguments = cgi.FieldStorage()
    if 'claim' in arguments:
        return host_with_claims, "demo_scope_gathering"
    else:
        return host_without_claims, "demo_scope_non_gathering"
