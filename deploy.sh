NGINX_CONF="/etc/nginx/nginx.conf"
# NGINX_CONF=~/oncall/configs/nginx.conf
declare -A INSTANCES

# Mappings
INSTANCES["oncall-a"]="8081"
INSTANCES["oncall-b"]="8082"

check_health() {
  local port=$1
  local url="http://localhost:$port/"
  if curl --output /dev/null --silent --head --fail "$url"; then
    echo "Port $port is healthy"
    return 0
  else
    echo "Waiting for port $port to be healthy"
    return 1
  fi
}

reload_config() {
  sudo nginx -s reload
}

remove_traffic() {
  sudo sed -i "/server localhost:$1;/d" $NGINX_CONF
  reload_config
}

restart() {
  docker restart "oncall-$1-1" 1> /dev/null
}

add_traffic() {
  sudo sed -i "/upstream oncall-web {/a\        server localhost:$1;" $NGINX_CONF
  reload_config
}

for instance in "${!INSTANCES[@]}"
do
    port="${INSTANCES[$instance]}"
    echo "Removing traffic from $instance"
    remove_traffic "${INSTANCES[$instance]}"
    echo "Deploying new version on $instance"
    restart $instance
    while ! check_health $port; do
      sleep 2
    done
    echo "Adding traffic to $instance"
    add_traffic "${INSTANCES[$instance]}"
done
