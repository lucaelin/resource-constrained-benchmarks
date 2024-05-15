FROM python:3.12.3-slim

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

# Copy the start script into the container
COPY start.sh /app/start.sh

# Use the start script as the entrypoint
ENTRYPOINT ["/app/start.sh"]
