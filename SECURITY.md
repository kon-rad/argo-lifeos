# Security

argo-lifeos is built to hold sensitive personal data, so security reports are welcome and taken seriously.

**Report privately** through GitHub's "Report a vulnerability" button on this repository (Security tab). Please don't open a public issue for a vulnerability.

Particularly in scope:

- Any way a device or agent token can read data, or read above its sensitivity tier
- Row-level security bypasses
- Raw blobs readable without the right `age` identity
- `forget()` leaving data behind (rows, blobs, embeddings, summaries)
- Personal data leaking into logs or error messages
