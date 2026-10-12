-- argo-lifeos 0001: the event spine, sources, cursors, entities.
-- Plain Postgres 14+, no extensions. Vectors (pgvector) and geography (PostGIS)
-- come in later migrations so the core runs on a stock server.

BEGIN;

CREATE TABLE source (
  name            text PRIMARY KEY,                -- matches event.source
  connector_ver   text,
  max_sensitivity smallint NOT NULL DEFAULT 1 CHECK (max_sensitivity BETWEEN 0 AND 3),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Saved only after the batch it covers has committed.
CREATE TABLE cursor (
  source      text PRIMARY KEY REFERENCES source(name) ON UPDATE CASCADE,
  value       text NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Raw originals live encrypted in object storage; this is the index of them.
CREATE TABLE blob (
  sha256      text PRIMARY KEY CHECK (sha256 ~ '^[0-9a-f]{64}$'),
  mime        text NOT NULL,
  bytes       bigint,
  tier        smallint NOT NULL CHECK (tier BETWEEN 0 AND 3),  -- which age recipient encrypted it
  stored_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE event (
  id                   text PRIMARY KEY,           -- ULID, time-sortable
  source               text NOT NULL REFERENCES source(name) ON UPDATE CASCADE,
  kind                 text NOT NULL,
  during               tstzrange NOT NULL,         -- instants are [t,t]
  timeframe_end        timestamptz,                -- "sometime between lower(during) and this"
  tz                   text,
  tz_origin            text CHECK (tz_origin IN ('explicit','device','location','inferred','unknown')),
  time_uncertainty_ms  integer CHECK (time_uncertainty_ms >= 0),
  lat                  double precision CHECK (lat BETWEEN -90 AND 90),
  lon                  double precision CHECK (lon BETWEEN -180 AND 180),
  coord_uncertainty_m  real CHECK (coord_uncertainty_m >= 0),
  title                text,
  sensitivity          smallint NOT NULL CHECK (sensitivity BETWEEN 0 AND 3),
  raw_ref              text REFERENCES blob(sha256),
  dedupe_key           text NOT NULL,
  payload              jsonb NOT NULL DEFAULT '{}'::jsonb,
  connector_ver        text NOT NULL,
  ingested_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source, dedupe_key),
  CHECK ((lat IS NULL) = (lon IS NULL)),
  CHECK (NOT isempty(during))
);

CREATE INDEX event_during_brin ON event USING brin (lower(during));
CREATE INDEX event_during_gist ON event USING gist (during);
CREATE INDEX event_kind_start  ON event (kind, lower(during));

-- Deleted things stay deleted on re-import: forget() records the key, not the content.
CREATE TABLE tombstone (
  source      text NOT NULL,
  dedupe_key  text NOT NULL,
  forgotten_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (source, dedupe_key)
);

-- Entities: a person/place/org has many attributes; events attach to attributes.
CREATE TABLE entity (
  id          bigserial PRIMARY KEY,
  type        text NOT NULL CHECK (type IN ('person','place','org','pet','project')),
  name        text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE attribute (
  id          bigserial PRIMARY KEY,
  name        text NOT NULL,                       -- 'email', 'phone', 'handle:telegram', 'geofence'
  value       text NOT NULL,
  UNIQUE (name, value)
);

CREATE TABLE entity_attribute (
  entity_id     bigint NOT NULL REFERENCES entity(id) ON DELETE CASCADE,
  attribute_id  bigint NOT NULL REFERENCES attribute(id) ON DELETE CASCADE,
  PRIMARY KEY (entity_id, attribute_id)
);

-- Named relations between events, or from an event to an attribute.
CREATE TABLE relation (
  id             serial PRIMARY KEY,
  label          text NOT NULL UNIQUE,            -- 'photo of', 'attached to', 'with', 'at'
  directed       boolean NOT NULL DEFAULT true,
  subordinating  boolean NOT NULL DEFAULT false
);

CREATE TABLE link (
  id                 bigserial PRIMARY KEY,
  relation_id        integer NOT NULL REFERENCES relation(id),
  from_event_id      text NOT NULL REFERENCES event(id) ON DELETE CASCADE,
  to_event_id        text REFERENCES event(id) ON DELETE CASCADE,
  to_attribute_id    bigint REFERENCES attribute(id) ON DELETE CASCADE,
  confidence         real NOT NULL DEFAULT 1 CHECK (confidence > 0 AND confidence <= 1),
  CHECK ((to_event_id IS NULL) <> (to_attribute_id IS NULL))
);
CREATE INDEX link_from ON link (from_event_id);
CREATE INDEX link_to_event ON link (to_event_id) WHERE to_event_id IS NOT NULL;

INSERT INTO relation (label, directed, subordinating) VALUES
  ('photo of',    true,  false),
  ('attached to', true,  true),
  ('in reply to', true,  false),
  ('with',        false, false),
  ('at',          true,  false);

COMMIT;
