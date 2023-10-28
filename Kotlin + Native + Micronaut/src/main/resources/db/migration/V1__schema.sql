-- Create the Event table if it does not exist
CREATE TABLE IF NOT EXISTS Event (
									 id SERIAL PRIMARY KEY,
									 aggregate_uuid TEXT NOT NULL,
									 data TEXT NOT NULL
);

-- Create the index on aggregateUUID if it does not exist
CREATE INDEX IF NOT EXISTS idx_aggregate ON Event (aggregate_uuid);