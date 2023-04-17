while true; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" http://prod.local:8080)

    if [[ $status_code -eq 200 ]]; then
        echo -e "\033[32m$status_code\033[0m"
    else
        echo -e "\033[31m$status_code\033[0m"
    fi

    sleep 2
done