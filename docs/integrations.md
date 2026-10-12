# Integrations with the Argo products

LifeOS is headless. Each product below is a client with its own token and its own UI.

## Argo journal (private AI journal, iOS)

The journal is **zero-knowledge**: entries are encrypted on the device with a key the journal's server never holds. The integration keeps that promise, so journal text never passes through the journal's server on its way to or from LifeOS.

| # | Pattern | Data path | Status |
|---|---|---|---|
| A | **Day context in** | Phone → the user's own LifeOS `/v1/days/{date}`, with URL + app token in the Keychain. The journal server isn't in the path | First |
| B | **Suggested entries from wearable memos** | Memo → LifeOS → phone pulls today's memos → user accepts → encrypted on the phone | Second |
| C | **Journal out** | Phone decrypts and posts entries to LifeOS as tier-3 events | Opt-in only. Once exported, that copy is protected by the user's LifeOS, not by the journal's zero-knowledge design, and the setting must say so |
| D | Through the journal's server | — | Never: it would break zero-knowledge |

Day context can feed the journal's on-device views (a "your day" card, maps of places) and its AI features, which already send plaintext for a single request at a time.

HealthKit and background location belong in a separate open-source companion app (`ios/`), not in the journal.

## argo-exo (wearable deck)

The deck is LifeOS's **edge node**.

| Signal | Trigger | Event kind |
|---|---|---|
| Push-to-talk memo | Mic button | `utterance` + audio blob → transcript |
| Photo / video | Camera button | `media_item` with current location |
| Mark this moment | Programmable button hold | `bookmark` |
| Meal | Photo in meal mode | `meal` (vision → macros → confirm) |
| Body sensors, ring | Collectors | `sample` series |

`lifeos-edge` (in `edge/`) is an outbox. Every capture goes to local SQLite and disk first, then forwards to `/v1/ingest` with a device token when the network is reachable. Retries are idempotent, and local blobs are deleted only after LifeOS confirms the upload.

Back to the wearer: a kiosk **Now** panel reads `/v1/now`; voice questions go to an agent that calls the MCP tools.

## Notes vault (second brain)

| Direction | What |
|---|---|
| LifeOS → app | Timeline, Day, Now and health pages built with `@argo-lifeos/ui` |
| LifeOS → app search | The app runs its own search and `/v1/search`, then merges the results |
| LifeOS → vault | One daily markdown summary note per day, plus memos tagged as notes into an inbox folder |
| Vault → LifeOS | A connector emits "worked on" events from file changes and git commits |
| Agent transcripts → LifeOS | Agent conversation archives as events |
