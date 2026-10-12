# Architecture Decision Record

Newest first. Each entry: **Status**, **Context**, **Decision**, **Consequences**.

## ADR-0005: Push-to-talk audio only

**Status:** Accepted (2026-10-12)

**Context:** Always-on wearable audio is the largest and most sensitive stream a lifelog can collect, and it records bystanders.

**Decision:** Audio is captured only while the wearer presses push-to-talk. Raw audio is kept; transcripts are tier 2 and searchable (full text + semantic).

**Consequences:** Volume is small, so no purge policy is needed. Other people are recorded only when the wearer chooses to, with the device's recording light on. Always-on capture is out of scope.

## ADR-0004: AGPL-3.0

**Status:** Accepted (2026-10-12)

**Context:** The project holds personal life data. Timelinize, the closest prior art, is AGPL-3.0, and its import parsers are worth porting.

**Decision:** License the project under AGPL-3.0.

**Consequences:** Hosted forks must publish their source. Code ported from Timelinize keeps its copyright notice and attribution in a `NOTICE` file.

## ADR-0003: Headless core; UI through a shared component package

**Status:** Accepted (2026-10-12)

**Context:** The data shows up in several places: a notes app, a wearable kiosk, an iOS journal, agents. One bundled UI would duplicate the notes app; iframe embeds mean two logins and styling that can't match.

**Decision:** The core exposes REST, NDJSON ingest, SSE, MCP and SQL read roles, with no UI. `@argo-lifeos/ui` ships data-in React components. A thin reference web app uses only the public API.

**Consequences:** API response shapes are the shared UI contract and are versioned. Native apps render the same JSON with native views.

## ADR-0002: Build our own core; borrow from Timelinize

**Status:** Accepted (2026-10-12)

**Context:** Timelinize (Go + SQLite, AGPL-3.0) is the closest open-source project. As of its 2026-05 source, it imports files and pulls APIs but has no push ingestion (its issue #31 was open), its local API is unauthenticated, it has no encryption at rest, and its README warns the schema is unstable.

**Decision:** Build a TypeScript + Postgres core with push ingestion, tokens, tiers and encryption. Adopt Timelinize's ideas: time-offset origin and uncertainty, coordinate uncertainty, the entity/attribute split, named relations, and dedupe that remembers deletions. Port its parsers as connectors over time.

**Consequences:** More work up front, but we own the schema and roadmap. A `timelinize-sqlite` connector can read an existing Timelinize database for backfill.

## ADR-0001: Raw immutable and encrypted; everything else rebuildable

**Status:** Accepted (2026-10-12)

**Context:** Schemas, enrichment models and connectors will change over the years.

**Decision:** Originals are content-addressed and encrypted in object storage. Normalized Parquet and Postgres are derived and can be replayed with `lifeos rebuild`.

**Consequences:** Storage roughly doubles for small records. In return, schema changes are replays rather than migrations of irreplaceable data.
