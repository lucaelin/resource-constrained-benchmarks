FROM pypy:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

# Copy the start script into the container
COPY start.sh /app/start.sh

# Use the start script as the entrypoint
ENTRYPOINT ["/app/start.sh"]
