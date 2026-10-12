# argo-lifeos

<!-- TODO(konrad): write the opening pitch for this repo before announcing it. -->

TODO(konrad): one paragraph on what argo-lifeos is and why it exists.

**Status:** design stage. The architecture, the data contract and the first database migration are here; the ingest service is not built yet. See [docs/roadmap.md](docs/roadmap.md).

## What it is, technically

A self-hosted, headless service for quantified-self and life-logging data. Devices and connectors push timestamped events into it (sleep, location, meals, push-to-talk memos, web history, calendar, email, sensor series). It stores the originals encrypted and keeps a queryable index. Clients read from it through an API, an MCP server for agents, and read-only SQL roles.

It has no UI of its own beyond a thin reference app. Screens live in the apps that use it.

argo-lifeos is part of the Argo set of products:

| Product | Role next to LifeOS |
|---|---|
| [Argo journal](https://myargoquest.com) (iOS, [source](https://github.com/kon-rad/luminalog-oss)) | Private, zero-knowledge AI journal. Pulls day context from your LifeOS straight from the device, and gets suggested entries from wearable memos |
| [argo-exo](https://github.com/kon-rad/argo-exo) | Wearable deck. Acts as LifeOS's edge node: push-to-talk memos, photos, "mark this moment", body sensors, plus a Now panel on its kiosk |
| Second brain | A personal knowledge vault. Gets a daily markdown summary and Timeline / Day views; its activity flows back as events |

## Repo map

| Path | What |
|---|---|
| `docs/philosophy.md` | The principles the design is held to |
| `docs/architecture.md` | Components, storage, API surface, tokens, sensitivity tiers |
| `docs/connector-contract.md` | How to write a connector in any language (NDJSON over stdout) |
| `docs/integrations.md` | How the Argo journal, the Exo wearable and a notes vault connect |
| `docs/adr.md` | Architecture decision record, newest first |
| `docs/roadmap.md` | Phases and what "done" means for each |
| `schema/event.schema.json` | The public data contract: one JSON Schema for every NDJSON line |
| `schema/migrations/` | Postgres migrations, plain SQL |
| `scripts/check-public.sh` | Fails if anything private (IPs, emails, denylisted strings) is about to be committed |

Planned (see the roadmap): `core/` (ingest + API), `workers/`, `mcp/`, `sdk/`, `connectors/`, `edge/`, `ui/`, `web/`, `ios/`, `deploy/`.

## Try the schema

```bash
createdb lifeos_dev
for f in schema/migrations/*.sql; do psql -v ON_ERROR_STOP=1 -d lifeos_dev -f "$f"; done
```

## License

[AGPL-3.0](LICENSE). If you run a modified version as a service, you share the source. That's on purpose: this holds people's lives, and forks should stay open.

Contributing: [CONTRIBUTING.md](CONTRIBUTING.md). Security: [SECURITY.md](SECURITY.md).
