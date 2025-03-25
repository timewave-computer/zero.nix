print_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required Options (and Environment Variables):"
    echo "  -c, --command <value>         Specify the node command to execute."
    echo "      \$COMMAND                   (or set COMMAND in the environment)"
    echo "  -p, --contract-path <path>    Path to the contract file."
    echo "      \$CONTRACT_PATH             (or set CONTRACT_PATH in the environment)"
    echo "  -i, --chain-id <id>           Set the chain ID."
    echo "      \$CHAIN_ID                  (or set CHAIN_ID in the environment)"
    echo "  -a, --admin-address <addr>    Address of the contract administrator."
    echo "      \$ADMIN_ADDRESS             (or set ADMIN_ADDRESS in the environment)"
    echo "  -n, --node-address <addr>     Chain node (RPC) address to connect to."
    echo "      \$NODE_ADDRESS               (or set NODE_ADDRESS in the environment)"
    echo "  -m, --max-fees <amount>       Maximum fees allowed for any single transaction (don't include denom here)."
    echo "      \$MAX_FEES                  (or set MAX_FEES in the environment)"
    echo "  -d, --denom <denom>       Maximum transaction fees allowed."
    echo "      \$DENOM                     (or set DENOM in the environment)"
    echo ""
    echo "Optional Options (and Environment Variables):"
    echo "  -g, --gas-multiplier <num>    Gas multiplier for transactions (default: 1.5)."
    echo "      \$GAS_MULTIPLIER            (or set GAS_MULTIPLIER in the environment)"
    echo "  -f, --from-address <addr>     Sender's address for transactions. (default: Admin Address)"
    echo "      \$FROM_ADDRESS              (or set FROM_ADDRESS in the environment)"
    echo "  -l, --contract-label <label>  Label for the contract."
    echo "      \$CONTRACT_LABEL            (or set CONTRACT_LABEL in the environment) (default: basename of contract with .wasm removed)"
    echo "  -D, --data-file <path>        File to store contract info. (default: ./\$(basename \$COMMAND)-contracts.yaml)"
    echo "      \$DATA_FILE                  (or set DATA_FILE in the environment)"
    echo "  -s, --source <string>         URI or Path that the contract is sourced from to be included in data file."
    echo "      \$SOURCE                     (or set SOURCE in the environment)"
    echo "  -N, --node-home <path>        Data directory to pass node command. (default: node data folder in \$HOME)"
    echo "      \$NODE_HOME                  (or set NODE_HOME in the environment)"
    echo "  -k, --keyring-backend <value> Keyring backend to use. (default: test)"
    echo "      \$KEYRING_BACKEND           (or set KEYRING_BACKEND in the environment)"
    echo "  -I, --instantiate             Instantiate contract after uploading it."
    echo "      \$INSTANTIATE               (or set INSTANTIATE to 1 in the environment)"
    echo "  -S, --initial-state <value>   Initial state to instantiate with (only takes affect when -I/--instantiate/\$INSTANTIATE is passed)"
    echo "      \$INITIAL_STATE             (or set INITIAL_STATE in the environment)"
    echo "  -h, --help                    Display this help menu and exit."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Example:"
    echo "  $0 --command gaiad --contract-path my_contract.wasm --chain-id localcosmoshub-1"
    echo ""
}

# Required Values
COMMAND=${COMMAND:-""}
CONTRACT_PATH=${CONTRACT_PATH:-""}
CHAIN_ID=${CHAIN_ID:-""}
ADMIN_ADDRESS=${ADMIN_ADDRESS:-""}
NODE_ADDRESS=${NODE_ADDRESS:-""}
DENOM=${DENOM:-""}
MAX_FEES=${MAX_FEES:-""}

# Optional Values with dynamic defaults set later
FROM_ADDRESS=${FROM_ADDRESS:-""}     # Defaults to final value of $ADMIN_ADDRESS
CONTRACT_LABEL=${CONTRACT_LABEL:-""} # Defaults to basename of $CONTRACT_PATH with .wasm removed
NODE_HOME=${NODE_HOME:-""}           # --home will not be passed to $COMMAND unless this this is set
DATA_FILE=${DATA_FILE:-""}            # Defaults to $(basename $COMMAND)-contracts.json
SOURCE=${SOURCE:-""}                 # Defaults to $CONTRACT_PATH

# Optional values with static defaults
GAS_MULTIPLIER=${GAS_MULTIPLIER:-"1.5"}
KEYRING_BACKEND=${KEYRING_BACKEND:-"test"}
INSTANTIATE=${INSTANTIATE:-"0"}
INITIAL_STATE=${INITIAL_STATE:-'{}'}

HELP=0
declare -A REQUIRED_VARS_MAP=(
    ["COMMAND"]="-c|--command"
    ["CONTRACT_PATH"]="-p|--contract-path"
    ["ADMIN_ADDRESS"]="-a|--admin-address"
    ["CHAIN_ID"]="-i|--chain-id"
    ["NODE_ADDRESS"]="-n|--node-address"
    ["MAX_FEES"]="-m|--max-fees"
    ["DENOM"]="-d|--denom"
)
# Define short options
SHORT_OPTS="c:p:i:a:n:d:m:g:f:l:D:s:k:N:IS:h"
# Define long options (split into multiple lines for readability)
LONG_OPTS="
command:
contract-path:
chain-id:
admin-address:
node-address:
denom:
max-fees:
gas-multiplier:
from-address:
contract-label:
data-file:
source:
keyring-backend:
node-home:
instantiate
initial-state:
help
"

# Use `getopt` with formatted options
parse_opts() {
    getopt -o "$SHORT_OPTS" -l "$(echo "$LONG_OPTS" | tr '\n[:space:]' ',')" -n "$0" -- "$@"
}
if ! parse_opts "$@"; then
    echo "Failed to parse options." >&2
    print_help
    exit 1
fi

eval set -- "$(parse_opts "$@")"
while true; do
    case "$1" in
    -c | --command)
        COMMAND="$2"
        shift 2
        ;;
    -p | --contract-path)
        CONTRACT_PATH="$2"
        shift 2
        ;;
    -i | --chain-id)
        CHAIN_ID="$2"
        shift 2
        ;;
    -a | --admin-address)
        ADMIN_ADDRESS="$2"
        shift 2
        ;;
    -n | --node-address)
        NODE_ADDRESS="$2"
        shift 2
        ;;
    -d | --denom)
        DENOM="$2"
        shift 2
        ;;
    -m | --max-fees)
        MAX_FEES="$2"
        shift 2
        ;;
    -g | --gas-multiplier)
        GAS_MULTIPLIER="$2"
        shift 2
        ;;
    -f | --from-address)
        FROM_ADDRESS="$2"
        shift 2
        ;;
    -l | --contract-label)
        CONTRACT_LABEL="$2"
        shift 2
        ;;
    -D | --data-file)
        DATA_FILE="$2"
        shift 2
        ;;
    -s | --source)
        SOURCE="$2"
        shift 2
        ;;
    -k | --keyring-backend)
        KEYRING_BACKEND="$2"
        shift 2
        ;;
    -N | --node-home)
        KEYRING_BACKEND="$2"
        shift 2
        ;;
    -I | --instantiate)
        INSTANTIATE="1"
        shift 1
        ;;
    -S | --initial-state)
        INITIAL_STATE="$2"
        shift 2
        ;;
    -h | --help)
        HELP=1
        shift
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Unexpected option: $1" >&2
        exit 1
        ;;
    esac
done

# Immediately print help menu if requested, ignore any other errors
if [[ $HELP -eq 1 ]]; then
    print_help
    exit 0
fi

# Make sure all required variables are included
# Exit if any are missing, print missing options, then print help menu
MISSING_VARS=()
for VAR in "${!REQUIRED_VARS_MAP[@]}"; do
    if [[ -z "${!VAR}" ]]; then
        MISSING_VARS+=("${REQUIRED_VARS_MAP[$VAR]} (or set $VAR in the environment)")
    fi
done
if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    echo "Error: The following required options are missing:" >&2
    for var in "${MISSING_VARS[@]}"; do
        echo "  $var" >&2
    done
    echo "" >&2
    print_help
    exit 1
fi
if [[ -z "$CONTRACT_LABEL" ]]; then
    CONTRACT_LABEL="$(basename "$CONTRACT_PATH" .wasm)"
fi
if [[ -z "$FROM_ADDRESS" ]]; then
    FROM_ADDRESS="$ADMIN_ADDRESS"
fi
if [[ -z "$DATA_FILE" ]]; then
    DATA_FILE="$(basename "$COMMAND")-contracts.json"
fi
if [[ -z "$SOURCE" ]]; then
    SOURCE="$CONTRACT_PATH"
fi

COMMON_FLAGS=("--keyring-backend=$KEYRING_BACKEND" "--node=$NODE_ADDRESS")
if [ -n "$NODE_HOME" ]; then
    COMMON_FLAGS+=("--home=$NODE_HOME")
fi

store_contract() {
    $COMMAND tx wasm store "$CONTRACT_PATH" --from "$FROM_ADDRESS" --gas-adjustment "$GAS_MULTIPLIER" \
        --gas auto --chain-id "$CHAIN_ID" "${COMMON_FLAGS[@]}" --output json --yes "$@"
}

instantiate_contract() {
    $COMMAND tx wasm instantiate "$CODE_ID" "$INITIAL_STATE" --yes "${COMMON_FLAGS[@]}" --output=json \
        --admin "$ROOT_ADDRESS" --from "$ROOT_ADDRESS" --label "$CONTRACT_LABEL" --chain-id "$CHAIN_ID" "$@"
}

query_hash() {
    $COMMAND query tx "$TXHASH" --node "$NODE_ADDRESS" --output json
}

extract_fee() {
    yq .raw_log | grep -oP 'required: [^0-9]*\K[0-9]+(\.[0-9]+)?'"$DENOM" |
        awk -F"$DENOM" '{printf "%f", ($1*1.5)}'
}

set_contract_attr() {
    yq -iy '."'"$CONTRACT_LABEL"'"."'"$1"'" = '"$2" "$DATA_FILE"
}

if [[ ! -f "$DATA_FILE" ]]; then
    echo '{}' > "$DATA_FILE"
fi

CONTRACT_HASH=$(sha256sum "$CONTRACT_PATH" | awk '{print $1}')
UPDATE_NEEDED=false
if yq -e 'has("'"$CONTRACT_LABEL"'")' "$DATA_FILE" > /dev/null; then
    echo "contract $CONTRACT_LABEL has already been created, checking to see if contract has changed from previous upload"
    if yq -e '."'"$CONTRACT_LABEL"'" | has("hash")' "$DATA_FILE" > /dev/null; then
        EXISTING_HASH=$(yq -r '."'"$CONTRACT_LABEL"'".hash' "$DATA_FILE")
        if [[ "$CONTRACT_HASH" == "$EXISTING_HASH" ]]; then
            echo "contract $CONTRACT_LABEL has remain unchanged, skipping"
        else
            echo "contract $CONTRACT_LABEL has changed, will update now"
            UPDATE_NEEDED=true
        fi
    else
        echo "No entry for contract hash indicating previous failure, will update now"
        UPDATE_NEEDED=true
    fi
else
    UPDATE_NEEDED=true
fi

if [[ "$UPDATE_NEEDED" == true ]]; then
    echo "Starting upload of contract $CONTRACT_LABEL"
    STORE_FEES=$(store_contract --fees "0.01$DENOM" | extract_fee)
    echo "Found fees for storing contract to be $STORE_FEES$DENOM"
    if awk "BEGIN {exit !($STORE_FEES > $MAX_FEES)}"; then
        echo "Error: store fee of $STORE_FEES is greater than maximum specified fee of $MAX_FEES"
        exit 1
    fi
    echo "storing contract"
    TXHASH=$(store_contract --fees "$STORE_FEES$DENOM" | yq -r '.txhash')
    while ! query_hash > /dev/null; do
        echo "waiting for tx hash $TXHASH for contract $CONTRACT_LABEL to be available"
        sleep 1
    done
    CODE_ID=$(query_hash | yq -r '.events[].attributes[] | select(.key == "code_id") | .value')
    echo "found code id to be $CODE_ID"
    set_contract_attr code_id "\"$CODE_ID\""

    if [[ $INSTANTIATE -eq 1 ]]; then
        INST_FEES=$(instantiate_contract --fees "0.01$DENOM" | extract_fee)
        echo "Found fees for instantiating contract to be $INST_FEES$DENOM"
        if awk "BEGIN {exit !($INST_FEES > $MAX_FEES)}"; then
            echo "Error: instantiate fee of $INST_FEES is greater than maximum specified fee of $MAX_FEES"
            exit 1
        fi
        echo "Instantiating contract"
        instantiate_contract --fees "$INST_FEES$DENOM"
        while query_contract | yq -e '.contracts | length == 0'; do
            echo "waiting for contract address to be available"
            sleep 1
        done
        ADDRESSES_JSON=$(query_contract | yq -c '.contracts')
        set_contract_attr addresses "$ADDRESSES_JSON"
        echo "Successfully uploaded $CONTRACT_LABEL contract with code id $CODE_ID"
    fi
    set_contract_attr hash "\"$CONTRACT_HASH\""
    set_contract_attr source "\"$SOURCE\""
fi
