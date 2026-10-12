# Architecture

## Overview

```
 CAPTURE                     CORE (headless)                         STORE
 ───────                     ───────────────                         ─────
 wearable edge outbox ──┐    lifeosd                                 RAW: object storage (S3/B2-compatible)
 phone location app   ──┤    ├─ POST /v1/ingest  NDJSON + blobs      content-addressed, age-encrypted
 phone companion      ──┼──► ├─ REST /v1/*       reads               LAKE: Parquet by source/date
 connectors (any lang)──┘    ├─ /v1/stream       SSE / webhooks      HOT: Postgres (event spine,
                             ├─ MCP server       agent tools              typed tables, full text, vectors)
                             └─ SQL read roles   tier-scoped RLS
                                    │
                             workers: transcription, vision → macros,
                             stay detection, embeddings, daily rollups

 CLIENTS: notes-vault app · reference web app · wearable kiosk · journal app (iOS) · agents (MCP)
```

## Storage tiers

| Tier | Holds | Format | Rebuildable from |
|---|---|---|---|
| Raw | Originals exactly as captured: audio, photos, JSON payloads, exports | Content-addressed blobs (`sha256`), encrypted with `age` before upload | — (source of truth) |
| Lake | Normalized history | Parquet, partitioned `source/yyyy/mm/dd` | Raw + connector version |
| Hot | What you query | Postgres | Raw or lake |

Losing Postgres loses nothing: `lifeos rebuild --source X --since D` replays normalization from raw.

## Data model

**The event spine.** One `event` row per thing that happened: source, kind, time range, local time zone and how the offset was known, time uncertainty, optional coordinates with uncertainty, sensitivity tier, raw blob pointer, dedupe key, JSON payload, connector version. See [`schema/migrations/0001_event_spine.sql`](../schema/migrations/0001_event_spine.sql).

**Typed domain tables** hang off the spine where a domain needs real columns: `sample` (dense metric series), `sleep_session`, `location_fix`, `stay` / `trip`, `meal` + `meal_item`, `web_visit`, `email_message`, `calendar_event`, `media_item`, `utterance` (push-to-talk memo + transcript).

**Entities.** People, places, organisations. A person *has* many attributes (email addresses, phone numbers, handles); events attach to attributes, which resolve to entities. Event-to-event links use named relations ("photo of", "attached to", "in reply to"). The approach is adapted from [Timelinize](https://github.com/timelinize/timelinize)'s model.

## API surface

| Interface | For |
|---|---|
| `POST /v1/ingest` (NDJSON) | Connectors, edge devices, phone apps |
| REST `/v1/*` | Apps |
| MCP server | Agents |
| `/v1/stream` (SSE, webhooks) | Clients that react to new events |
| SQL read roles | Notebooks, power users |

| Endpoint | Returns |
|---|---|
| `GET /v1/days/{date}` | Sleep, day start, meals + macros, stays, calendar, top sites, emails, memos, media, links to entities |
| `GET /v1/timeline?from&to&bucket` | Bucketed lanes for zoomable timeline strips |
| `GET /v1/events?from&to&kind&source` | Paged events |
| `GET /v1/series/{metric}?from&to&res` | Downsampled series |
| `GET /v1/search?q&from&to&kind` | Hybrid full-text + semantic search |
| `GET /v1/now` | Current context: place, last sleep, next calendar item, today's totals, last memo |
| `GET /v1/entities/{id}` | A person or place across time |
| `POST /v1/log` | A quick typed fact ("lunch: ramen", "mark this moment") |
| `POST /v1/forget` | Delete a range or event everywhere (owner only) |

MCP tools: `lifeos.now`, `lifeos.day`, `lifeos.search`, `lifeos.series`, `lifeos.log`. `forget` is deliberately not exposed to agents.

**The JSON response shapes are the shared UI contract.** React clients use `@argo-lifeos/ui` (data-in components: Timeline, DayCard, Hypnogram, SeriesChart, TrackMap, MemoList, MealCard). Native clients render the same JSON. Response shapes are versioned with the API.

## Security

### Sensitivity tiers

| Tier | Examples | LLM access |
|---|---|---|
| 0 public | On-chain activity, public posts | Any provider |
| 1 personal | Calendar, web visits, sleep, meals, steps | Third-party LLMs allowed |
| 2 private | Email bodies, GPS fixes, photos, push-to-talk memos and transcripts | Local models or zero-retention endpoints only |
| 3 intimate | Health labs, journal exports, anything the owner marks | Local models only |

Postgres row-level security enforces the tier per role.

### Tokens

| Token | Can | Typical holder |
|---|---|---|
| Owner session | Everything, including `forget` and tier 3 | The owner in a browser (password + TOTP) |
| Device token | `ingest` only, for its own `source` | A wearable, a phone |
| Agent token | Read ≤ tier 2, `log` | Agent profiles, via MCP |
| App token | Read ≤ its declared tier | A notes app, a journal app |
| SQL read role | `SELECT` on views ≤ tier N | Notebooks |

A leaked device token can write fake events under one source, and read nothing.

### Keys

- Raw blobs: `age`, one recipient per tier. The tier-3 identity should live off the server (owner laptop + paper backup), so a compromised server can't read tier-3 raw data.
- Transport: private network (e.g. Tailscale/WireGuard) or TLS with tokens; the ingest port shouldn't face the public internet.
- Connector credentials live in the deployment's env file, never in the repo.
