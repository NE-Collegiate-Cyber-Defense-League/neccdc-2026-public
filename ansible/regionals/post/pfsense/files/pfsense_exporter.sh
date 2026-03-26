#!/bin/sh
# =============================================================================
# node_pfsense_exporter.sh — Combined pfSense Metrics Exporter
#
# Collects and exports:
#   - Firewall (pf) state table and per-interface packet/byte stats
#   - Gateway status (delay, stddev, loss, up/down)
#   - Interface traffic statistics (bytes, packets, errors, drops)
#   - WireGuard tunnel statistics (peer up, handshake, rx/tx bytes)
#
# Install: /usr/local/etc/prom_exporters/node_pfsense_exporter.sh
# Cron:    */1 * * * * root /usr/local/etc/prom_exporters/node_pfsense_exporter.sh
# Output:  /var/tmp/node_exporter/node_pfsense_*.prom (one file per section)
# =============================================================================

OUTDIR="/var/tmp/node_exporter"
WG_IFACE="tun_wg0"

mkdir -p "$OUTDIR"

# Output files — one per section
OUT_FIREWALL="${OUTDIR}/node_pfsense_firewall.prom"
OUT_GATEWAY="${OUTDIR}/node_pfsense_gateway.prom"
OUT_INTERFACE="${OUTDIR}/node_pfsense_interface.prom"
OUT_WIREGUARD="${OUTDIR}/node_pfsense_wireguard.prom"
OUT_UNBOUND="${OUTDIR}/node_pfsense_unbound.prom"

# Temp files
TMP_FIREWALL="${OUT_FIREWALL}.tmp"
TMP_GATEWAY="${OUT_GATEWAY}.tmp"
TMP_INTERFACE="${OUT_INTERFACE}.tmp"
TMP_WIREGUARD="${OUT_WIREGUARD}.tmp"
TMP_UNBOUND="${OUT_UNBOUND}.tmp"

# Helper: emit a metric line only if the value field is a non-empty number.
# Usage: emit_metric "label_line" "value"
emit_metric() {
    _line="$1"
    _val="$2"
    # Accept integers and floats (including negative); reject empty or non-numeric
    case "$_val" in
        ''|*[!0-9.eE+-]*) return ;;   # empty or non-numeric → skip
        *) ;;
    esac
    # Secondary check: must start with a digit, '-', or '+'
    case "$_val" in
        [0-9]*|[-+][0-9]*) printf '%s\n' "$_line $_val" ;;
        *) ;;
    esac
}

# =============================================================================
# Data Collection Phase - Capture all data once
# =============================================================================

# Firewall data
SI_DATA=$(pfctl -si 2>/dev/null)
SM_DATA=$(pfctl -sm 2>/dev/null)
PF_IF_DATA=$(pfctl -vvsI 2>/dev/null | awk '
    /^[a-zA-Z]/ { iface=$1; wanted=(iface ~ /ena|tun_wg/) }
    wanted && /\/(Pass|Block):/ {
        label=$1; sub(/:$/,"",label)
        if (label ~ /^In/)  direction="in";  else direction="out"
        if (label ~ /4/)    proto="ipv4";    else proto="ipv6"
        if (label ~ /Pass/) action="pass";   else action="block"
        pkts=$4; bytes=$6
        print iface, direction, proto, action, pkts, bytes
    }')

# Gateway data
GW_DATA=$(/usr/local/sbin/pfSsh.php playback gatewaystatus 2>/dev/null \
    | awk 'NR>1 && NF>=8 && $1 !~ /^\[/')

# Interface statistics
IF_DATA=$(
    for IFACE in $(ifconfig -l | tr ' ' '\n' | grep -E 'ena|tun_wg'); do
        netstat -inb -I "$IFACE" 2>/dev/null | awk '$3 ~ /^<Link/'
    done | awk '{
        if ($4 ~ /^\(/) {
            print $1, $6, $7, $8, $9, $10, $11, $12, $13
        } else {
            print $1, $5, $6, $7, $8, $9, $10, $11, $12
        }
    }'
)

# WireGuard data
WG_CONF="/usr/local/etc/wireguard/${WG_IFACE}.conf"
WG_DUMP=$(wg show "$WG_IFACE" dump 2>/dev/null)
WG_IF_UP=$(ifconfig "$WG_IFACE" 2>/dev/null | awk 'NR==1 && /UP/ {print 1; exit} NR==1 {print 0}')
[ -z "$WG_IF_UP" ] && WG_IF_UP=0
WG_PEER_DATA=$(echo "$WG_DUMP" | awk 'NR>1 && NF>=7')
NOW=$(date +%s)

# Unbound DNS data
# stats_noreset avoids clearing counters on each scrape (safe for Prometheus counters)
UNBOUND_CONF="/var/unbound/unbound.conf"
UNBOUND_DATA=$(unbound-control -c "$UNBOUND_CONF" stats_noreset 2>/dev/null)

# Parse tunnel description from config (first # Description: line)
WG_TUNNEL_DESC=$(awk '/^# Description:/ { sub(/^# Description: */, ""); print; exit }' "$WG_CONF" 2>/dev/null)
[ -z "$WG_TUNNEL_DESC" ] && WG_TUNNEL_DESC="$WG_IFACE"

# Parse peer name map from config: emit "PUBKEY<TAB>PEER_NAME" per [Peer] block.
# The peer name is taken from the "# Peer: <name>" comment immediately above each [Peer] block.
WG_PEER_MAP=$(awk '
    /^# Peer:/  { sub(/^# Peer: */, ""); peer_name = $0 }
    /^PublicKey/ { print $3 "\t" peer_name; peer_name = "" }
' "$WG_CONF" 2>/dev/null)

# Lookup helper: resolve a public key to its human-readable peer name.
# Falls back to the public key itself if no match is found in the config.
wg_peer_name() {
    _key="$1"
    _name=$(printf '%s\n' "$WG_PEER_MAP" \
        | awk -F'\t' -v key="$_key" '$1 == key { print $2; exit }')
    [ -z "$_name" ] && _name="$_key"
    printf '%s' "$_name"
}

# =============================================================================
# Section: Firewall Statistics → node_pfsense_firewall.prom
# =============================================================================

> "$TMP_FIREWALL"

printf '# HELP node_pfsense_pf_state_entries Current number of state table entries\n' >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_state_entries gauge\n'                                   >> "$TMP_FIREWALL"
echo "$SI_DATA" | awk '/current entries/ {print $3}' | while read val; do
    emit_metric "node_pfsense_pf_state_entries" "$val"
done >> "$TMP_FIREWALL"

printf '\n# HELP node_pfsense_pf_state_entries_max State table hard limit (max entries)\n' >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_state_entries_max gauge\n'                                   >> "$TMP_FIREWALL"
echo "$SM_DATA" | awk '/^states/ {print $4}' | while read val; do
    emit_metric "node_pfsense_pf_state_entries_max" "$val"
done >> "$TMP_FIREWALL"

printf '\n# HELP node_pfsense_pf_state_searches_total Total state table searches\n'    >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_state_searches_total counter\n'                          >> "$TMP_FIREWALL"
echo "$SI_DATA" | awk '/^  searches/ {print $2}' | while read val; do
    emit_metric "node_pfsense_pf_state_searches_total" "$val"
done >> "$TMP_FIREWALL"

printf '\n# HELP node_pfsense_pf_state_inserts_total Total state table inserts\n'      >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_state_inserts_total counter\n'                           >> "$TMP_FIREWALL"
echo "$SI_DATA" | awk '/^  inserts/ {print $2}' | while read val; do
    emit_metric "node_pfsense_pf_state_inserts_total" "$val"
done >> "$TMP_FIREWALL"

printf '\n# HELP node_pfsense_pf_state_removals_total Total state table removals\n'    >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_state_removals_total counter\n'                          >> "$TMP_FIREWALL"
echo "$SI_DATA" | awk '/^  removals/ {print $2}' | while read val; do
    emit_metric "node_pfsense_pf_state_removals_total" "$val"
done >> "$TMP_FIREWALL"

printf '\n# HELP node_pfsense_pf_packets_total Packets handled by pf per interface\n'  >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_packets_total counter\n'                                 >> "$TMP_FIREWALL"
echo "$PF_IF_DATA" | while read IFACE DIR PROTO ACTION PKTS BYTES; do
    emit_metric \
        "node_pfsense_pf_packets_total{interface=\"$IFACE\",direction=\"$DIR\",proto=\"$PROTO\",action=\"$ACTION\"}" \
        "$PKTS"
done >> "$TMP_FIREWALL"

printf '\n# HELP node_pfsense_pf_bytes_total Bytes handled by pf per interface\n'      >> "$TMP_FIREWALL"
printf '# TYPE node_pfsense_pf_bytes_total counter\n'                                   >> "$TMP_FIREWALL"
echo "$PF_IF_DATA" | while read IFACE DIR PROTO ACTION PKTS BYTES; do
    emit_metric \
        "node_pfsense_pf_bytes_total{interface=\"$IFACE\",direction=\"$DIR\",proto=\"$PROTO\",action=\"$ACTION\"}" \
        "$BYTES"
done >> "$TMP_FIREWALL"

mv "$TMP_FIREWALL" "$OUT_FIREWALL"

# =============================================================================
# Section: Gateway Statistics → node_pfsense_gateway.prom
# =============================================================================

> "$TMP_GATEWAY"

printf '# HELP node_pfsense_gateway_delay_ms Gateway round-trip delay in milliseconds\n' >> "$TMP_GATEWAY"
printf '# TYPE node_pfsense_gateway_delay_ms gauge\n'                                       >> "$TMP_GATEWAY"
echo "$GW_DATA" | while read NAME MONITOR SOURCE DELAY REST; do
    val=$(echo "$DELAY" | tr -d 'ms')
    emit_metric "node_pfsense_gateway_delay_ms{gateway=\"$NAME\",monitor=\"$MONITOR\"}" "$val"
done >> "$TMP_GATEWAY"

printf '\n# HELP node_pfsense_gateway_stddev_ms Gateway RTT standard deviation in milliseconds\n' >> "$TMP_GATEWAY"
printf '# TYPE node_pfsense_gateway_stddev_ms gauge\n'                                             >> "$TMP_GATEWAY"
echo "$GW_DATA" | while read NAME MONITOR SOURCE DELAY STDDEV REST; do
    val=$(echo "$STDDEV" | tr -d 'ms')
    emit_metric "node_pfsense_gateway_stddev_ms{gateway=\"$NAME\",monitor=\"$MONITOR\"}" "$val"
done >> "$TMP_GATEWAY"

printf '\n# HELP node_pfsense_gateway_loss_percent Gateway packet loss percentage\n' >> "$TMP_GATEWAY"
printf '# TYPE node_pfsense_gateway_loss_percent gauge\n'                             >> "$TMP_GATEWAY"
echo "$GW_DATA" | while read NAME MONITOR SOURCE DELAY STDDEV LOSS REST; do
    val=$(echo "$LOSS" | tr -d '%')
    emit_metric "node_pfsense_gateway_loss_percent{gateway=\"$NAME\",monitor=\"$MONITOR\"}" "$val"
done >> "$TMP_GATEWAY"

printf '\n# HELP node_pfsense_gateway_up Gateway online status (1=online, 0=down)\n' >> "$TMP_GATEWAY"
printf '# TYPE node_pfsense_gateway_up gauge\n'                                        >> "$TMP_GATEWAY"
echo "$GW_DATA" | while read NAME MONITOR SOURCE DELAY STDDEV LOSS STATUS REST; do
    [ -z "$NAME" ] && continue
    [ "$STATUS" = "online" ] && UP=1 || UP=0
    emit_metric "node_pfsense_gateway_up{gateway=\"$NAME\",monitor=\"$MONITOR\"}" "$UP"
done >> "$TMP_GATEWAY"

mv "$TMP_GATEWAY" "$OUT_GATEWAY"

# =============================================================================
# Section: Interface Statistics → node_pfsense_interface.prom
# =============================================================================

> "$TMP_INTERFACE"

printf '# HELP node_pfsense_interface_rx_bytes_total Total bytes received on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_rx_bytes_total counter\n'                              >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_rx_bytes_total{interface=\"$NAME\"}" "$IBYTES"
done >> "$TMP_INTERFACE"

printf '\n# HELP node_pfsense_interface_tx_bytes_total Total bytes transmitted on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_tx_bytes_total counter\n'                                >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_tx_bytes_total{interface=\"$NAME\"}" "$OBYTES"
done >> "$TMP_INTERFACE"

printf '\n# HELP node_pfsense_interface_rx_packets_total Total packets received on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_rx_packets_total counter\n'                               >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_rx_packets_total{interface=\"$NAME\"}" "$IPKTS"
done >> "$TMP_INTERFACE"

printf '\n# HELP node_pfsense_interface_tx_packets_total Total packets transmitted on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_tx_packets_total counter\n'                                  >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_tx_packets_total{interface=\"$NAME\"}" "$OPKTS"
done >> "$TMP_INTERFACE"

printf '\n# HELP node_pfsense_interface_rx_errors_total Total receive errors on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_rx_errors_total counter\n'                              >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_rx_errors_total{interface=\"$NAME\"}" "$IERRS"
done >> "$TMP_INTERFACE"

printf '\n# HELP node_pfsense_interface_tx_errors_total Total transmit errors on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_tx_errors_total counter\n'                               >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_tx_errors_total{interface=\"$NAME\"}" "$OERRS"
done >> "$TMP_INTERFACE"

printf '\n# HELP node_pfsense_interface_rx_drops_total Total dropped inbound packets on interface\n' >> "$TMP_INTERFACE"
printf '# TYPE node_pfsense_interface_rx_drops_total counter\n'                                      >> "$TMP_INTERFACE"
echo "$IF_DATA" | while read NAME IPKTS IERRS IDROP IBYTES OPKTS OERRS OBYTES COLL; do
    emit_metric "node_pfsense_interface_rx_drops_total{interface=\"$NAME\"}" "$IDROP"
done >> "$TMP_INTERFACE"

mv "$TMP_INTERFACE" "$OUT_INTERFACE"

# =============================================================================
# Section: WireGuard Statistics → node_pfsense_wireguard.prom
# =============================================================================

> "$TMP_WIREGUARD"

# Interface-level metric — includes tunnel description from config
printf '# HELP node_pfsense_wg_interface_up WireGuard interface up state (1=up, 0=down)\n' >> "$TMP_WIREGUARD"
printf '# TYPE node_pfsense_wg_interface_up gauge\n'                                         >> "$TMP_WIREGUARD"
emit_metric "node_pfsense_wg_interface_up{interface=\"$WG_IFACE\",tunnel=\"$WG_TUNNEL_DESC\"}" "$WG_IF_UP" >> "$TMP_WIREGUARD"

# Peer-level metrics — include both the raw pubkey and the human-readable name from config
printf '\n# HELP node_pfsense_wg_peer_up Peer considered up (1=handshake within 3 minutes)\n' >> "$TMP_WIREGUARD"
printf '# TYPE node_pfsense_wg_peer_up gauge\n'                                                >> "$TMP_WIREGUARD"
echo "$WG_PEER_DATA" | while read PUBKEY PSK ENDPOINT ALLOWED LAST_HS RX TX KEEPALIVE; do
    [ -z "$PUBKEY" ] && continue
    PEER_NAME=$(wg_peer_name "$PUBKEY")
    if [ "$LAST_HS" -eq 0 ] 2>/dev/null; then
        PEER_UP=0
    elif [ $((NOW - LAST_HS)) -le 180 ]; then
        PEER_UP=1
    else
        PEER_UP=0
    fi
    emit_metric "node_pfsense_wg_peer_up{interface=\"$WG_IFACE\",tunnel=\"$WG_TUNNEL_DESC\",peer=\"$PUBKEY\",peer_name=\"$PEER_NAME\"}" "$PEER_UP"
done >> "$TMP_WIREGUARD"

printf '\n# HELP node_pfsense_wg_peer_last_handshake_seconds Seconds since last successful handshake (0=never)\n' >> "$TMP_WIREGUARD"
printf '# TYPE node_pfsense_wg_peer_last_handshake_seconds gauge\n'                                                >> "$TMP_WIREGUARD"
echo "$WG_PEER_DATA" | while read PUBKEY PSK ENDPOINT ALLOWED LAST_HS RX TX KEEPALIVE; do
    [ -z "$PUBKEY" ] && continue
    PEER_NAME=$(wg_peer_name "$PUBKEY")
    if [ "$LAST_HS" -eq 0 ] 2>/dev/null; then
        HS_AGE=0
    else
        HS_AGE=$((NOW - LAST_HS))
    fi
    emit_metric "node_pfsense_wg_peer_last_handshake_seconds{interface=\"$WG_IFACE\",tunnel=\"$WG_TUNNEL_DESC\",peer=\"$PUBKEY\",peer_name=\"$PEER_NAME\"}" "$HS_AGE"
done >> "$TMP_WIREGUARD"

printf '\n# HELP node_pfsense_wg_peer_rx_bytes_total Total bytes received from peer\n' >> "$TMP_WIREGUARD"
printf '# TYPE node_pfsense_wg_peer_rx_bytes_total counter\n'                           >> "$TMP_WIREGUARD"
echo "$WG_PEER_DATA" | while read PUBKEY PSK ENDPOINT ALLOWED LAST_HS RX TX KEEPALIVE; do
    [ -z "$PUBKEY" ] && continue
    PEER_NAME=$(wg_peer_name "$PUBKEY")
    emit_metric "node_pfsense_wg_peer_rx_bytes_total{interface=\"$WG_IFACE\",tunnel=\"$WG_TUNNEL_DESC\",peer=\"$PUBKEY\",peer_name=\"$PEER_NAME\"}" "$RX"
done >> "$TMP_WIREGUARD"

printf '\n# HELP node_pfsense_wg_peer_tx_bytes_total Total bytes sent to peer\n' >> "$TMP_WIREGUARD"
printf '# TYPE node_pfsense_wg_peer_tx_bytes_total counter\n'                     >> "$TMP_WIREGUARD"
echo "$WG_PEER_DATA" | while read PUBKEY PSK ENDPOINT ALLOWED LAST_HS RX TX KEEPALIVE; do
    [ -z "$PUBKEY" ] && continue
    PEER_NAME=$(wg_peer_name "$PUBKEY")
    emit_metric "node_pfsense_wg_peer_tx_bytes_total{interface=\"$WG_IFACE\",tunnel=\"$WG_TUNNEL_DESC\",peer=\"$PUBKEY\",peer_name=\"$PEER_NAME\"}" "$TX"
done >> "$TMP_WIREGUARD"

mv "$TMP_WIREGUARD" "$OUT_WIREGUARD"

# =============================================================================
# Section: Unbound DNS Statistics → node_pfsense_unbound.prom
# =============================================================================
# Helper: extract a single key=value from UNBOUND_DATA
# Usage: unbound_val "total.num.queries"
unbound_val() {
    printf '%s\n' "$UNBOUND_DATA" | awk -F= -v k="$1" '$1==k { print $2; exit }'
}

> "$TMP_UNBOUND"

# --- Uptime / timing ---
printf '# HELP node_unbound_up_seconds_total Seconds since unbound started\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_up_seconds_total counter\n'                        >> "$TMP_UNBOUND"
emit_metric "node_unbound_up_seconds_total" "$(unbound_val time.up)"          >> "$TMP_UNBOUND"

# --- Total query counters ---
printf '\n# HELP node_unbound_queries_total Total number of queries received\n'         >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_queries_total counter\n'                                     >> "$TMP_UNBOUND"
emit_metric "node_unbound_queries_total"                 "$(unbound_val total.num.queries)"            >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_cache_hits_total Queries answered from cache\n'           >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_cache_hits_total counter\n'                                  >> "$TMP_UNBOUND"
emit_metric "node_unbound_cache_hits_total"              "$(unbound_val total.num.cachehits)"          >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_cache_misses_total Queries not answered from cache\n'     >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_cache_misses_total counter\n'                                >> "$TMP_UNBOUND"
emit_metric "node_unbound_cache_misses_total"            "$(unbound_val total.num.cachemiss)"          >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_prefetch_total Cache prefetch operations\n'               >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_prefetch_total counter\n'                                   >> "$TMP_UNBOUND"
emit_metric "node_unbound_prefetch_total"                "$(unbound_val total.num.prefetch)"           >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_queries_timed_out_total Queries that timed out\n'         >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_queries_timed_out_total counter\n'                           >> "$TMP_UNBOUND"
emit_metric "node_unbound_queries_timed_out_total"       "$(unbound_val total.num.queries_timed_out)"  >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_queries_discard_timeout_total Queries discarded due to timeout\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_queries_discard_timeout_total counter\n'                            >> "$TMP_UNBOUND"
emit_metric "node_unbound_queries_discard_timeout_total" "$(unbound_val total.num.queries_discard_timeout)" >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_recursive_replies_total Replies sent after full recursion\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_recursive_replies_total counter\n'                              >> "$TMP_UNBOUND"
emit_metric "node_unbound_recursive_replies_total"       "$(unbound_val total.num.recursivereplies)"   >> "$TMP_UNBOUND"

# --- Request list gauges ---
printf '\n# HELP node_unbound_requestlist_current_all Current queries in the request list\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_requestlist_current_all gauge\n'                                  >> "$TMP_UNBOUND"
emit_metric "node_unbound_requestlist_current_all"  "$(unbound_val total.requestlist.current.all)"  >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_requestlist_exceeded_total Queries dropped because request list was full\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_requestlist_exceeded_total counter\n'                                         >> "$TMP_UNBOUND"
emit_metric "node_unbound_requestlist_exceeded_total" "$(unbound_val total.requestlist.exceeded)"         >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_requestlist_overwritten_total Queries overwritten in request list\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_requestlist_overwritten_total counter\n'                                >> "$TMP_UNBOUND"
emit_metric "node_unbound_requestlist_overwritten_total" "$(unbound_val total.requestlist.overwritten)" >> "$TMP_UNBOUND"

# --- Recursion timing ---
printf '\n# HELP node_unbound_recursion_time_avg_seconds Average time to resolve recursive queries\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_recursion_time_avg_seconds gauge\n'                                        >> "$TMP_UNBOUND"
emit_metric "node_unbound_recursion_time_avg_seconds"    "$(unbound_val total.recursion.time.avg)"    >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_recursion_time_median_seconds Median time to resolve recursive queries\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_recursion_time_median_seconds gauge\n'                                       >> "$TMP_UNBOUND"
emit_metric "node_unbound_recursion_time_median_seconds" "$(unbound_val total.recursion.time.median)" >> "$TMP_UNBOUND"

# --- Answer rcodes (labelled) ---
printf '\n# HELP node_unbound_answer_rcode_total Answers sent per DNS response code\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_answer_rcode_total counter\n'                               >> "$TMP_UNBOUND"
for RCODE in NOERROR FORMERR SERVFAIL NXDOMAIN NOTIMPL REFUSED nodata; do
    VAL=$(unbound_val "num.answer.rcode.${RCODE}")
    emit_metric "node_unbound_answer_rcode_total{rcode=\"${RCODE}\"}" "$VAL"
done >> "$TMP_UNBOUND"

# --- Query types (labelled) ---
printf '\n# HELP node_unbound_query_type_total Queries received per DNS record type\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_query_type_total counter\n'                                 >> "$TMP_UNBOUND"
printf '%s\n' "$UNBOUND_DATA" | awk -F= '/^num\.query\.type\./ {
    split($1, a, "."); print a[4], $2
}' | while read QTYPE VAL; do
    emit_metric "node_unbound_query_type_total{type=\"${QTYPE}\"}" "$VAL"
done >> "$TMP_UNBOUND"

# --- Transport breakdown ---
printf '\n# HELP node_unbound_queries_ipv6_total Queries received over IPv6\n'  >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_queries_ipv6_total counter\n'                        >> "$TMP_UNBOUND"
emit_metric "node_unbound_queries_ipv6_total"  "$(unbound_val num.query.ipv6)"  >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_queries_tcp_total Queries received over TCP\n'    >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_queries_tcp_total counter\n'                         >> "$TMP_UNBOUND"
emit_metric "node_unbound_queries_tcp_total"   "$(unbound_val num.query.tcp)"   >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_queries_tls_total Queries received over TLS\n'    >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_queries_tls_total counter\n'                         >> "$TMP_UNBOUND"
emit_metric "node_unbound_queries_tls_total"   "$(unbound_val num.query.tls)"   >> "$TMP_UNBOUND"

# --- Security ---
printf '\n# HELP node_unbound_answers_secure_total Answers that were DNSSEC validated\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_answers_secure_total counter\n'                               >> "$TMP_UNBOUND"
emit_metric "node_unbound_answers_secure_total" "$(unbound_val num.answer.secure)"        >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_answers_bogus_total Answers that failed DNSSEC validation\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_answers_bogus_total counter\n'                                  >> "$TMP_UNBOUND"
emit_metric "node_unbound_answers_bogus_total"  "$(unbound_val num.answer.bogus)"           >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_unwanted_queries_total Queries blocked by access control\n'  >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_unwanted_queries_total counter\n'                               >> "$TMP_UNBOUND"
emit_metric "node_unbound_unwanted_queries_total" "$(unbound_val unwanted.queries)"         >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_unwanted_replies_total Unsolicited or non-matching replies\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_unwanted_replies_total counter\n'                                >> "$TMP_UNBOUND"
emit_metric "node_unbound_unwanted_replies_total" "$(unbound_val unwanted.replies)"          >> "$TMP_UNBOUND"

# --- Cache entry counts ---
printf '\n# HELP node_unbound_msg_cache_count Current entries in message cache\n'    >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_msg_cache_count gauge\n'                                  >> "$TMP_UNBOUND"
emit_metric "node_unbound_msg_cache_count"   "$(unbound_val msg.cache.count)"        >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_rrset_cache_count Current entries in RRset cache\n'   >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_rrset_cache_count gauge\n'                                >> "$TMP_UNBOUND"
emit_metric "node_unbound_rrset_cache_count" "$(unbound_val rrset.cache.count)"      >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_infra_cache_count Current entries in infrastructure cache\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_infra_cache_count gauge\n'                                      >> "$TMP_UNBOUND"
emit_metric "node_unbound_infra_cache_count" "$(unbound_val infra.cache.count)"             >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_key_cache_count Current entries in DNSSEC key cache\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_key_cache_count gauge\n'                                   >> "$TMP_UNBOUND"
emit_metric "node_unbound_key_cache_count"   "$(unbound_val key.cache.count)"         >> "$TMP_UNBOUND"

# --- Memory usage ---
printf '\n# HELP node_unbound_memory_bytes Memory used by unbound subsystems\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_memory_bytes gauge\n'                                 >> "$TMP_UNBOUND"
for SUBSYS in cache.rrset cache.message mod.iterator mod.validator; do
    VAL=$(unbound_val "mem.${SUBSYS}")
    LABEL=$(printf '%s' "$SUBSYS" | tr '.' '_')
    emit_metric "node_unbound_memory_bytes{subsystem=\"${LABEL}\"}" "$VAL"
done >> "$TMP_UNBOUND"

# --- Per-thread metrics (queries, cache hits/misses, recursion time, queue depth) ---
# BSD awk (pfSense/FreeBSD) does not support 3-arg match(); use sub() to strip the
# key prefix and leave just the thread number.
printf '\n# HELP node_unbound_thread_queries_total Queries received per thread\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_thread_queries_total counter\n'                        >> "$TMP_UNBOUND"
printf '%s\n' "$UNBOUND_DATA" | awk -F= '/^thread[0-9]+\.num\.queries=/ {
    tid = $1; sub(/^thread/, "", tid); sub(/\..*/, "", tid); print tid, $2
}' | while read TID VAL; do
    emit_metric "node_unbound_thread_queries_total{thread=\"${TID}\"}" "$VAL"
done >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_thread_cache_hits_total Cache hits per thread\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_thread_cache_hits_total counter\n'                  >> "$TMP_UNBOUND"
printf '%s\n' "$UNBOUND_DATA" | awk -F= '/^thread[0-9]+\.num\.cachehits=/ {
    tid = $1; sub(/^thread/, "", tid); sub(/\..*/, "", tid); print tid, $2
}' | while read TID VAL; do
    emit_metric "node_unbound_thread_cache_hits_total{thread=\"${TID}\"}" "$VAL"
done >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_thread_cache_misses_total Cache misses per thread\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_thread_cache_misses_total counter\n'                    >> "$TMP_UNBOUND"
printf '%s\n' "$UNBOUND_DATA" | awk -F= '/^thread[0-9]+\.num\.cachemiss=/ {
    tid = $1; sub(/^thread/, "", tid); sub(/\..*/, "", tid); print tid, $2
}' | while read TID VAL; do
    emit_metric "node_unbound_thread_cache_misses_total{thread=\"${TID}\"}" "$VAL"
done >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_thread_requestlist_current Current request list depth per thread\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_thread_requestlist_current gauge\n'                                    >> "$TMP_UNBOUND"
printf '%s\n' "$UNBOUND_DATA" | awk -F= '/^thread[0-9]+\.requestlist\.current\.all=/ {
    tid = $1; sub(/^thread/, "", tid); sub(/\..*/, "", tid); print tid, $2
}' | while read TID VAL; do
    emit_metric "node_unbound_thread_requestlist_current{thread=\"${TID}\"}" "$VAL"
done >> "$TMP_UNBOUND"

printf '\n# HELP node_unbound_thread_recursion_time_avg_seconds Avg recursion time per thread\n' >> "$TMP_UNBOUND"
printf '# TYPE node_unbound_thread_recursion_time_avg_seconds gauge\n'                            >> "$TMP_UNBOUND"
printf '%s\n' "$UNBOUND_DATA" | awk -F= '/^thread[0-9]+\.recursion\.time\.avg=/ {
    tid = $1; sub(/^thread/, "", tid); sub(/\..*/, "", tid); print tid, $2
}' | while read TID VAL; do
    emit_metric "node_unbound_thread_recursion_time_avg_seconds{thread=\"${TID}\"}" "$VAL"
done >> "$TMP_UNBOUND"

mv "$TMP_UNBOUND" "$OUT_UNBOUND"