# Roadmap

| Phase | Ships | Done when |
|---|---|---|
| **0. Design** ✅ | Philosophy, architecture, connector contract, event schema, first migration, ADRs | This repo |
| **1. Headless core** | `core/` (ingest, `/v1/days`, `/v1/search`, `/v1/now`, tokens, RLS), `mcp/`, `sdk/ts`; first connectors: ring (Ultrahuman) and agent-conversation archive | An agent answers "how did I sleep on Tuesday?" through MCP, and `rebuild` replays a source from raw identically |
| **2. Faces + easy sources** | `ui/` components, `web/` reference app, daily markdown summary; connectors: OwnTracks/Overland, Chrome history, ActivityWatch, calendar | A full day page and a daily summary note from real data |
| **3. Wearable edge** | `edge/` outbox on the deck, push-to-talk memos → transcripts → search, kiosk Now panel, mark-this-moment | A memo is findable by a word in it and by place within the hour |
| **4. Journal** | Day context in the Argo journal (pattern A), then suggested entries from memos (B) | Behind a feature flag in a journal build |
| **5. Enrichment** | Meal photo → macros, email with marketing filter, photo library connector (Immich), people and places linking | A week of confirmed meals with protein totals |
| **6. Phone companion + launch** | `ios/` (HealthKit, background location), `deploy/` Docker Compose, connector registry | Someone else runs it from the README |
