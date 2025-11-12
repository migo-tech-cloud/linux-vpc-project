#!/bin/bash
set -e

POLICY_FILE="config/policies.json"

if [ ! -f "$POLICY_FILE" ]; then
  echo "❌ Policy file not found: $POLICY_FILE"
  exit 1
fi

echo "============================================================"
echo "🔒 Applying Security Group Policies from $POLICY_FILE"
echo "============================================================"

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
  echo "Installing jq..."
  sudo apt update -y && sudo apt install -y jq
fi

# Read all namespaces from policy file
for ns in $(jq -r 'keys[]' "$POLICY_FILE"); do
  echo ""
  echo "🛡️ Applying rules for namespace: $ns"
  
  # Clear existing rules
  sudo ip netns exec $ns iptables -F
  sudo ip netns exec $ns iptables -X

  # Ingress rules
  echo "  ↳ Configuring ingress rules..."
  jq -c ".\"$ns\".ingress[]" "$POLICY_FILE" | while read -r rule; do
    port=$(echo "$rule" | jq -r '.port')
    proto=$(echo "$rule" | jq -r '.protocol')
    action=$(echo "$rule" | jq -r '.action')
    
    if [ "$proto" = "all" ]; then
      proto="tcp"
    fi

    if [ "$action" = "allow" ]; then
      sudo ip netns exec $ns iptables -A INPUT -p $proto --dport $port -j ACCEPT
      echo "    ✅ ALLOW $proto port $port"
    else
      sudo ip netns exec $ns iptables -A INPUT -p $proto --dport $port -j DROP
      echo "    🚫 DENY $proto port $port"
    fi
  done

  # Egress rules
  echo "  ↳ Configuring egress rules..."
  jq -c ".\"$ns\".egress[]" "$POLICY_FILE" | while read -r rule; do
    port=$(echo "$rule" | jq -r '.port')
    proto=$(echo "$rule" | jq -r '.protocol')
    action=$(echo "$rule" | jq -r '.action')

    if [ "$proto" = "all" ]; then
      proto="tcp"
    fi

    if [ "$action" = "allow" ]; then
      sudo ip netns exec $ns iptables -A OUTPUT -p $proto --dport $port -j ACCEPT
      echo "    ✅ ALLOW egress $proto port $port"
    else
      sudo ip netns exec $ns iptables -A OUTPUT -p $proto --dport $port -j DROP
      echo "    🚫 DENY egress $proto port $port"
    fi
  done
done

echo ""
echo "============================================================"
echo "✅ All firewall policies applied successfully!"
echo "============================================================"
