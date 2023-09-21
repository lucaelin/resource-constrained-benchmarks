#!/bin/sh

# Run the db_init script
flask db_init

# Start the Gunicorn server
gunicorn app:app -b 0.0.0.0:8080 --workers=4
