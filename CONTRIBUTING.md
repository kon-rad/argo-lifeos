# Contributing

The project is at the design stage, so the most useful contributions right now are:

- **Connectors.** Read [docs/connector-contract.md](docs/connector-contract.md). Any language works as long as it prints valid NDJSON.
- **Schema review.** Open an issue if `schema/event.schema.json` or the migrations can't represent a source you care about.
- **Prior art.** If an existing open-source tool already owns a domain well, we'd rather connect to it than rebuild it.

## Rules

- **No personal data in the repo.** That means no real exports, hostnames, IP addresses, emails or tokens, and fixtures must be synthetic. Run `scripts/check-public.sh` before you push; CI runs it and `gitleaks` on every push.
- **Architectural changes get an ADR** in `docs/adr.md`.
- **Code ported from AGPL projects** (e.g. Timelinize parsers) keeps its copyright header and gets a line in `NOTICE`.

By contributing you agree that your contribution is licensed under AGPL-3.0.
