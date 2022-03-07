#!/bin/bash
DIR=/root/massa/massa-client
NODEID=你的节点地址


cd $DIR
handle() {
  local wallet_info=$(./massa-client -j wallet_info)
  local wallet_address=$(jq -r "[.[]] | .[0].address_info.address // empty" <<<"$wallet_info")
  local candidate_rolls=$(jq -r "[.[]] | .[-1].address_info.rolls.candidate_rolls" <<<"$wallet_info")
  local balance=$(jq -r "[.[]] | .[-1].address_info.balance.candidate_ledger_info.balance" <<<"$wallet_info")
  local roll_count=$(bc -l <<<"$balance/100")
  if [ -z "$wallet_address" ]; then
    echo "️ Wallet not found."
  elif [ "$candidate_rolls" -eq "0" ]; then
    local response=$(./massa-client buy_rolls "$wallet_address" 1 0)
    if grep -q 'insuffisant balance' <<<"$response"; then
      echo "️ Not enough tokens to buy rolls, Need 100."
    else
      echo "✅✅✅ Done. Bought 1 roll."
    fi
  else
    echo " Everything is ok."
  fi
}

while true
do
    RESULT=$(timeout 5s ./massa-client get_status -j)
    if [ $? == 124 ];then
        echo "timeout, restart massa node"
        systemctl restart massad
        sleep 60s
        continue
    fi
    N=$(echo $RESULT | jq ".node_id")
    if [ $N != \"$NODEID\" ];then
        echo "result error, restart massa node"
        systemctl restart massad
        sleep 60s
        continue
    fi
    handle
    echo "nodeid: $N, sleep 300s"
    sleep 300s
done
