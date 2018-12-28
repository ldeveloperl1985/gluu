#!/usr/bin/python
from helper import *
from config import *

display_header()

# Client calls API without RPT token
ticket = get_ticket(host=host_without_claims)

# Get Permission access token
access_token = get_permission_access_token()

# Client calls AS UMA /token endpoint with permission ticket and client credentials
need_info, token, redirect_url = get_rpt(access_token, ticket)

# Client calls API Gateway with RPT token
if not need_info:
    call_gg_rpt(host=host_without_claims, rpt=token)

display_footer()
