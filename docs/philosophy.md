# Philosophy

## Three kinds of memory, one timeline

| | **LifeOS** | **Notes vault (second brain)** | **Journal** |
|---|---|---|---|
| Question it answers | What happened? | What do I know, what am I doing? | What did I feel, what does it mean? |
| Nature of data | Objective, machine-captured, high volume | Curated, written, linked | Subjective, intimate |
| Unit | Event | Note | Entry |
| Author | Devices and connectors | You + agents | You, alone |
| Trust model | Self-hosted, encrypted at rest, scoped tokens | Your files | Zero-knowledge (Argo journal) |

They don't share a database. They share **time** (first) and **place** (second), and each one copies only *summaries* of the others.

## Principles

| # | Principle | In practice |
|---|---|---|
| 1 | **Headless core, many faces** | The API is the product. If a UI needs something the API lacks, the API grows; there's no side door |
| 2 | **The day is the unit of meaning** | `GET /v1/days/{date}` is the main read. Journals, vault summaries, briefings and kiosks all speak "day" |
| 3 | **Capture is cheap, recall is the product** | Design effort goes to search, Day and Now |
| 4 | **Raw is sacred, derived is disposable** | Originals are immutable and content-addressed; every table can be rebuilt from raw + code version |
| 5 | **Summaries flow up, raw stays down** | Other apps get day summaries and links, never the raw GPS table |
| 6 | **Each store keeps its own trust model** | LifeOS never weakens a zero-knowledge journal; integrations run device-direct |
| 7 | **Edge-first, offline-tolerant** | Wearables and phones write to a local outbox first; every write is idempotent |
| 8 | **Agents are clients with capability tokens** | An agent reads up to a sensitivity tier and can `log`; it never holds the owner token |
| 9 | **Every write says who wrote it** | `source` shows whether a fact was sensed, typed or inferred, and by what |
| 10 | **Sensitivity is a column** | Each event carries a tier that row-level security enforces, including for LLM access |
| 11 | **Forget is first-class** | `forget()` reaches raw blobs, rows, embeddings and derived summaries |
| 12 | **Integrate, don't rebuild** | Where a good open-source tool owns a domain (photos, desktop activity, phone location), write a connector to it |
| 13 | **Open contract, sovereign data** | The event schema is public and versioned. Apps are clients of *your* instance, never custodians of your life |
