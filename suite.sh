#!/bin/bash

TECH_STACK_VALUES=(
    'C# + .NET Core + ASP.NET'
    'Go + Native + Gin'
    'Java + JVM + Quarkus'
    'Java + JVM + Spring Boot 3'
    'Java + Native + Spring Boot 3'
    'Kotlin + JVM + Micronaut'
    'Kotlin + Native + Micronaut'
    'Kotlin + JVM + Ktor'
    'Python + CPython + Flask'
    'JavaScript + Node.js + Express'
    'JavaScript + Node.js + Fastify'
    'TypeScript + Deno + Express'
    'TypeScript + Bun + Express'
)

# Set the values for the APP_CPU_LIMIT and APP_MEM_LIMIT
APP_CPU_LIMIT_VALUES=(
#    "0.05" 
    "0.1" 
#    "0.2" 
    "0.5"
    "1.0"
#    "2.0"
)

APP_MEM_LIMIT_VALUES=(
#    "050M" 
#    "100M" 
    "200M"
    "400M"
)


for TECH_STACK in "${TECH_STACK_VALUES[@]}";
do
    # Loop through the values and run the bench.sh script
    for CPU_LIMIT in "${APP_CPU_LIMIT_VALUES[@]}"; 
    do
        for MEM_LIMIT in "${APP_MEM_LIMIT_VALUES[@]}"; 
        do
            APP_CPU_LIMIT=$CPU_LIMIT APP_MEM_LIMIT=$MEM_LIMIT timeout 30m ./bench.sh "$TECH_STACK";
            python3 ./plot.py "${CPU_LIMIT} Core - ${MEM_LIMIT}B";
            python3 ./plot.py "$TECH_STACK";
        done
    done
    python3 ./plot.py "$1";
done

spd-say "aim dann";
