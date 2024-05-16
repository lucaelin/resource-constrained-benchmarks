#!/bin/bash

export APP_CPU_LIMIT=${APP_CPU_LIMIT:-'0.5'}
export APP_MEM_LIMIT=${APP_MEM_LIMIT:-'200M'}
export SERVICE_NAME="${1//\//:-$SERVICE_NAME}" 

cd "$SERVICE_NAME"

# Create file to store timings
output_file="../results/${APP_CPU_LIMIT} Core - ${APP_MEM_LIMIT}B/${SERVICE_NAME}.txt"
mkdir "../results/${APP_CPU_LIMIT} Core - ${APP_MEM_LIMIT}B"
rm "$output_file"
touch "$output_file"
docker compose down -v

echo "time - 0 - 0 - $(date +"%Y-%m-%dT%H:%M:%S%z")" > "$output_file"
echo "instance - 0 - 0 - $(ec2metadata --instance-type)" > "$output_file"

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
  echo "date - $i - 0 - $(date +"%Y-%m-%dT%H:%M:%S%z")" > "$output_file"
  # Measure and record the time to start the service container
  start=$(date +%s.%N)
  docker compose up app -d
  end=$(date +%s.%N)
  start_time=$(echo "$end - $start" | bc)
  echo "compose up app - $i - 0 - $start_time seconds" >> "$output_file"

  echo "warmup"
  timeout 5m ../bench/warmup -run $i >> "$output_file"

  memory=$(docker stats --no-stream --no-trunc --format '{{.Name}} {{.MemUsage}}' | grep app-)
  echo "memory - $i - 1 - $memory" >> "$output_file"

  echo "bench 1"
  timeout 1m ../bench/bench -run=$i -connections=1 -duration=15 >> "$output_file"
  echo "bench 10"
  timeout 1m ../bench/bench -run=$i -connections=10 -duration=15 >> "$output_file"
  echo "bench 50"
  timeout 1m ../bench/bench -run=$i -connections=50 -duration=15 >> "$output_file"
  echo "bench 100"
  timeout 1m ../bench/bench -run=$i -connections=100 -duration=15 >> "$output_file"

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
