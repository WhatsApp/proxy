#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# License found in the LICENSE file in the root directory
# of this source tree.

curl -s -w 2 "http://127.0.0.1:8199/;csv" > /tmp/stats.txt || exit 1

# First trim off the leading line which is just "#"
# Then convert the ugly CSV to slightly less ugly JSON
# Filter out the lines for g_whatsapp_net backend status
# Select the "check_desc" field (Description of the check result)
# and take all results that do NOT equal "Layer4 check passed" from HAProxy
RESULT=$(tail -n +1 /tmp/stats.txt | jq -R 'split(",")' | jq -c '. | select(.[1] | contains("g_whatsapp_net"))' | jq --raw-output '.[65]| select(. | test("Layer4 check passed") | not)')

# # CSV output header row:
# # ["# pxname","svname","qcur","qmax","scur","smax","slim","stot","bin","bout","dreq","dresp","ereq","econ","eresp","wretr","wredis","status","weight","act","bck","chkfail","chkdown","lastchg","downtime","qlimit","pid","iid","sid","throttle","lbtot","tracked","type","rate","rate_lim","rate_max","check_status","check_code","check_duration","hrsp_1xx","hrsp_2xx","hrsp_3xx","hrsp_4xx","hrsp_5xx","hrsp_other","hanafail","req_rate","req_rate_max","req_tot","cli_abrt","srv_abrt","comp_in","comp_out","comp_byp","comp_rsp","lastsess","last_chk","last_agt","qtime","ctime","rtime","ttime","agent_status","agent_code","agent_duration","check_desc","agent_desc","check_rise","check_fall","check_health","agent_rise","agent_fall","agent_health","addr","cookie","mode","algo","conn_rate","conn_rate_max","conn_tot","intercepted","dcon","dses","wrew","connect","reuse","cache_lookups","cache_hits","srv_icur","src_ilim","qtime_max","ctime_max","rtime_max","ttime_max","eint","idle_conn_cur","safe_conn_cur","used_conn_cur","need_conn_est","uweight","agg_server_check_status","-","ssl_sess","ssl_reused_sess","ssl_failed_handshake","h2_headers_rcvd","h2_data_rcvd","h2_settings_rcvd","h2_rst_stream_rcvd","h2_goaway_rcvd","h2_detected_conn_protocol_errors","h2_detected_strm_protocol_errors","h2_rst_stream_resp","h2_goaway_resp","h2_open_connections","h2_backend_open_streams","h2_total_connections","h2_backend_total_streams",""]

if [ "$RESULT" != "" ]
then
  echo "[HEALTHCHECKER] Container failed healthchecks, L4 healthcheck on g.whatsapp.net failed"
  echo "[HEALTKCHECKER] Result $RESULT"
  exit -1;
fi

exit 0;

