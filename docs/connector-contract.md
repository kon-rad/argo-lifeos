# Connector contract

A connector is any executable, in any language, that pulls from one source and prints NDJSON. `lifeosd` does the rest: validation, blob upload, dedupe, cursor storage.

## Invocation

```
lifeos-connector-<name> sync --cursor <opaque-or-empty> --out -
```

The connector reads its credentials from environment variables declared in its manifest, prints records to stdout, and logs to stderr. Exit code 0 means the batch is complete.

## Records

Each line is one JSON object with a `type`, validated against [`schema/event.schema.json`](../schema/event.schema.json).

```json
{"type":"blob","sha256":"9f2c…","mime":"image/jpeg","path":"/tmp/lifeos/9f2c.jpg"}
{"type":"event","source":"telegram-meal","kind":"meal","start":"2026-10-12T12:31:00+09:00","dedupe_key":"tg:8812","sensitivity":1,"raw_ref":"9f2c…","payload":{"caption":"lunch"}}
{"type":"cursor","value":"8812"}
```

| Type | Meaning |
|---|---|
| `blob` | A raw original on local disk. `lifeosd` hashes it again, encrypts it and uploads it, then the connector may delete it |
| `event` | One thing that happened. `(source, dedupe_key)` is unique, so re-sending is harmless |
| `cursor` | Where the next run should start. Stored only after every earlier record in the batch has committed |

## Guarantees

- **At-least-once, idempotent.** A crash replays the batch; dedupe keys make that safe.
- **Cursor after commit.** A cursor is never saved ahead of the data it covers.
- **Provenance.** `lifeosd` stamps `connector_ver` and `ingested_at` on every row.

## Manifest

`connector.json` next to the executable:

```json
{
  "name": "chrome-history",
  "version": "0.1.0",
  "schedule": "hourly",
  "max_sensitivity": 1,
  "env": ["CHROME_PROFILE_DIR"],
  "kinds": ["web_visit"]
}
```

`lifeosd` refuses events above `max_sensitivity` from that connector.

## Push sources

Devices that generate data as it happens (a wearable, a phone location app) skip the CLI and `POST` the same NDJSON to `/v1/ingest` with a device token. The record format is identical.
