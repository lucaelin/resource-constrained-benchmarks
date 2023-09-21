#!/bin/bash

export APP_CPU_LIMIT=${APP_CPU_LIMIT:-'0.5'}
export APP_MEM_LIMIT=${APP_MEM_LIMIT:-'200M'}
export SERVICE_NAME="${1//\//:-$SERVICE_NAME}" 

cd "$SERVICE_NAME"

# Create file to store timings
output_file="../${APP_CPU_LIMIT} Core - ${APP_MEM_LIMIT}B/${SERVICE_NAME}.txt"
mkdir "../${APP_CPU_LIMIT} Core - ${APP_MEM_LIMIT}B"
rm "$output_file"
touch "$output_file"
docker compose down -v

sleep 3

start=$(date +%s.%N)
docker compose build
end=$(date +%s.%N)
build_time=$(echo "$end - $start" | bc)
echo "compose build - 0 - 0 - $build_time seconds" >> "$output_file"

# Measure and record the time and start the Docker containers
start=$(date +%s.%N)
docker compose up db -d
end=$(date +%s.%N)
db_startup_time=$(echo "$end - $start" | bc)
echo "compose up db - 0 - 0 - $db_startup_time seconds" >> "$output_file"

sleep 3

for i in {1..10}
do
  # Measure and record the time to start the service container
  start=$(date +%s.%N)
  docker compose up app -d
  end=$(date +%s.%N)
  start_time=$(echo "$end - $start" | bc)
  echo "compose up app - $i - 0 - $start_time seconds" >> "$output_file"

  # Measure and record the time for curl requests
  j=0
  compose_up_time=$(date +%s.%N)
  service_not_up_time=$(date +%s.%N)

  while [ $j -lt 100 ]
  do
    uuid=$(uuid)
    start=$(date +%s.%N)
    response=$(curl -s -o /dev/null --connect-timeout 0.5 -w "%{http_code}" http://localhost:8080/$uuid/query)
    end=$(date +%s.%N)
    request_time=$(echo "$end - $start" | bc)

    # If the request was successful (HTTP 200) and it's the first successful response, save the time
    if [ "$response" != "200" ]; then
      service_not_up_time=$(date +%s.%N)
      startup_time=$(echo "$service_not_up_time - $compose_up_time" | bc)
      sleep 0.1
    fi

    # If the request was successful (HTTP 200), increment the counter
    if [ "$response" == "200" ]; then
      if [ $j -eq 0 ]; then
        echo "service up - $i - 0 - $startup_time seconds" >> "$output_file"
        memory=$(docker stats --no-stream --no-trunc --format '{{.Name}} {{.MemUsage}}' | grep app-)
        echo "memory - $i - 0 - $memory" >> "$output_file"
      fi
      echo "curl request - $i - $(($j+1)) - $request_time seconds" >> "$output_file"
      j=$((j+1))
    fi

  done

  memory=$(docker stats --no-stream --no-trunc --format '{{.Name}} {{.MemUsage}}' | grep app-)
  echo "memory - $i - 1 - $memory" >> "$output_file"

  uuid=$(uuid)
  load_test=$(../wrk -t6 -c100 -d60s -s ../wrk-script.lua http://127.0.0.1:8080/)
  load_reqs=$(echo $load_test | grep Requests/sec)
  load_latency=$(echo $load_test | grep Latency)
  
  echo "load requests - $i - 1 - $load_reqs" >> "$output_file"
  echo "load latency - $i - 1 - $load_latency" >> "$output_file"

  memory=$(docker stats --no-stream --no-trunc --format '{{.Name}} {{.MemUsage}}' | grep app-)
  echo "memory - $i - 2 - $memory" >> "$output_file"

  # Measure and record the time to stop the service container
  start=$(date +%s.%N)
  docker compose stop app
  end=$(date +%s.%N)
  stop_time=$(echo "$end - $start" | bc)
  echo "compose stop app - $i - 0 - $stop_time seconds" >> "$output_file"
done


# Measure and record the time to shut down the Docker containers
start=$(date +%s.%N)
docker compose down
end=$(date +%s.%N)
shutdown_time=$(echo "$end - $start" | bc)
echo "compose down - 0 - 0 - $shutdown_time seconds" >> "$output_file"
