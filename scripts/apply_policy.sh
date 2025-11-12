#!/bin/bash
POLICY_FILE="config/policies.json"

for subnet in $(jq -c '.[]' $POLICY_FILE); do
    SUBNET=$(echo $subnet | jq -r '.subnet')
    for rule in $(echo $subnet | jq -c '.ingress[]'); do
        PORT=$(echo $rule | jq -r '.port')
        PROTO=$(echo $rule | jq -r '.protocol')
        ACTION=$(echo $rule | jq -r '.action')
        if [[ "$ACTION" == "allow" ]]; then
            iptables -A INPUT -s $SUBNET -p $PROTO --dport $PORT -j ACCEPT
        else
            iptables -A INPUT -s $SUBNET -p $PROTO --dport $PORT -j DROP
        fi
    done
done
echo "✅ Firewall policies applied"
