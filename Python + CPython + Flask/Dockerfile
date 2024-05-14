FROM python:3.12.3-alpine

WORKDIR /app

RUN apk add --no-cache --virtual build-dependencies libpq-dev build-base

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

RUN apk del --no-cache build-dependencies

COPY . .

# Copy the start script into the container
COPY start.sh /app/start.sh

# Use the start script as the entrypoint
ENTRYPOINT ["/app/start.sh"]
