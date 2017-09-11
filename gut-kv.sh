# gut-kv

# Set - Function to store a key and value
# Args:
#   filePath - Location to store key and value
#   key - Key name
#   value - value
_gut_set() {
  local filePath=$1
  local key=$2
  local value=$3

  # Check arguments
  if [ "$filePath" = "" ]; then
    echo "[gut-set] No file path provided"
    return 1;
  fi
  if [ "$key" = "" ]; then
    echo "[gut-set] No key provided"
    return 1;
  fi
  if [ "$value" = "" ]; then
    echo "[gut-set] No value provided"
    return 1;
  fi

  # Encode key and value
  local encodedKey=$(echo "$key" | base64)
  local encodedValue=$(echo "$value" | base64)
  local store="$encodedKey:$encodedValue"

  # Check if file exists
  local action=">"
  if [ ! -e "$filePath" ]; then
    # File does not exist, store
    echo ${store} >> ${filePath}
    return 0
  fi

  # Check if key exists
  local found=$(grep "$encodedKey:" "$filePath")
  local foundLine=$(awk "/"$encodedKey:"/{ print NR; exit }" "$filePath")
  if [ "$found" ]; then
    # Key found, update current key
    local awkC="{ if (NR == "$foundLine") print \""$store"\"; else print \$0}"
    awk "$awkC" "$filePath" > "$filePath".swap
    cat "$filePath".swap > "$filePath"
    rm "$filePath".swap
  else
    # Key not found, append key
    echo ${store} >> ${filePath}
  fi
}

# Get - Function to retrieve a key and value
# Args:
#   filePath - Location to retrieve key and value
#   key - Key name
#   value - value
_gut_get() {
  local filePath=$1
  local key=$2

  # Check arguments
  if [ "$filePath" = "" ]; then
    echo "[gut-get] No file path provided"
    return 1;
  fi
  if [ "$key" = "" ]; then
    echo "[gut-get] No key provided"
    return 1;
  fi

  # Check if file exists
  local action=">"
  if [ ! -e "$filePath" ]; then
    # File does not exist, return
    echo "[gut-get] File does not exist"
    return 1
  fi

  # Encode key
  local encodedKey=$(echo "$key" | base64)

  # Check if key exists
  local found=$(grep "$encodedKey:" "$filePath")
  local foundLine=$(awk "/"$encodedKey:"/{ print \$0; exit }" "$filePath")
  if [ "$found" ]; then
    # Key found, get key and decode it
    local encodedValue=$(echo "$foundLine" | awk -F':' "{ print \$2 }")
    local value=$(echo "$encodedValue" | base64 -D)
    echo $value
  fi
}
