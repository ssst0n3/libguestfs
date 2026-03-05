# AGENTS.md

## Mission
This repository exists to build the smallest practical container image that supports `virt-sparsify`.
Priority order:
1. Minimize image size.
2. Keep `virt-sparsify` functional.
3. Preserve common qcow2 workflow compatibility.
Non-goals unless requested:
- Broad guestfs tool coverage.
- Extra debugging utilities in runtime image.
- Convenience dependencies that increase image size.

## Repository Context
- Primary artifact: `Dockerfile`
- Release workflow: `.github/workflows/release-ghcr.yml`
- Build context filters: `.dockerignore`
- Default command: `virt-sparsify --help`
There is no package manifest or native unit test framework in this repo today.

## Build Commands
Use these commands by default.
- Local build:
  - `docker build -t libguestfs:local -f Dockerfile .`
- CI-parity build (recommended):
  - `docker build --platform linux/amd64 -t libguestfs:local -f Dockerfile .`
- Rebuild without cache:
  - `docker build --no-cache --platform linux/amd64 -t libguestfs:local -f Dockerfile .`

## Lint Commands
Run lint checks when changing Dockerfile or workflow files.
- Dockerfile lint (local):
  - `hadolint Dockerfile`
- Dockerfile lint (container fallback):
  - `docker run --rm -i hadolint/hadolint < Dockerfile`
- GitHub Actions lint:
  - `actionlint`
If tooling is unavailable, report that explicitly.

## Test Commands
No framework-based test suite exists; use smoke tests.
- Smoke test default command:
  - `docker run --rm libguestfs:local`
- Smoke test explicit command:
  - `docker run --rm libguestfs:local virt-sparsify --help`
- Binary presence check:
  - `docker run --rm libguestfs:local bash -lc "command -v virt-sparsify"`

## Running a Single Test (Important)
Because there is no test runner, one smoke command equals one test case.
Primary single test:
- `docker run --rm libguestfs:local virt-sparsify --help`
Secondary single test:
- `docker run --rm libguestfs:local bash -lc "command -v virt-sparsify"`
Optional minimal qcow2 test (after dependency changes):
- Create a tiny qcow2 sample image.
- Run one `virt-sparsify` pass.
- Keep it deterministic and lightweight.

## Acceptance Criteria
Any image-content change must satisfy all checks:
1. Build succeeds for `linux/amd64`.
2. `virt-sparsify --help` succeeds in container.
3. Final image size is measured and compared to baseline.
4. Compatibility tradeoffs are documented.

## Size Regression Policy
Size minimization is a hard requirement.
- Always record image size after Dockerfile changes.
- Include size delta versus previous baseline.
- If size increases, provide explicit justification.
- Reject unexplained size regressions.
Useful size commands:
- `docker image inspect libguestfs:local --format '{{.Size}}'`
- `docker images libguestfs:local`
- `docker history --no-trunc libguestfs:local`

## Dockerfile Style
### General
- Keep layers minimal and intentional.
- Prefer deterministic and reproducible instructions.
- Do not add packages unless required for `virt-sparsify` use cases.
### Package Installation
- Use `apt-get install -y --no-install-recommends`.
- Keep install and cleanup in one `RUN` layer.
- Keep package list short and justified.
- Re-validate each package necessity.
### Cleanup
- Clean apt metadata and package lists in same layer.
- Remove temporary files immediately.
- Preserve doc/man/locale pruning unless compatibility requires changes.
### Layer and Shell Hygiene
- Keep related apt operations in one `RUN` command.
- Format long command chains with clear indentation.
- Use `set -eux;` in complex Dockerfile `RUN` blocks.

## Code Style for Future Source Files
Apply these if source code is added later.
### Imports
- Group imports: standard library, third-party, local modules.
- Keep ordering consistent and formatter-friendly.
- Remove unused imports.
### Formatting
- Use UTF-8 with LF newlines.
- End files with one trailing newline.
- Avoid trailing whitespace.
- Keep lines readable (about 100-120 columns unless tool-enforced).
### Types
- Prefer explicit types on public interfaces.
- Avoid `any`/untyped escape hatches unless justified.
- Model nullable and optional values explicitly.
### Naming
- Use descriptive, intention-revealing names.
- Favor consistency over clever abbreviations.
- Follow language ecosystem naming norms.
### Error Handling
- Fail fast and surface actionable errors.
- Do not swallow failures silently.
- Include operational context in errors.
- In shell scripts, prefer `set -euo pipefail`.

## GitHub Actions Conventions
- Keep workflow permissions least-privilege.
- Pin actions by major version at minimum.
- Keep target platform explicit (`linux/amd64`) unless intentionally broadened.
- Preserve tag-driven release behavior unless requirements change.

## Security and Secrets
- Never commit credentials, tokens, or private keys.
- Use repository/organization secrets in CI.
- Avoid unverified remote install scripts in Dockerfile.

## Cursor and Copilot Rules Status
Rule scan results:
- `.cursor/rules/`: not found
- `.cursorrules`: not found
- `.github/copilot-instructions.md`: not found
If these files are added later, they are mandatory alongside this document.

## Agent Checklist
Before editing:
- Read `Dockerfile`, `.dockerignore`, and relevant workflow files.
After editing image contents:
- Rebuild for `linux/amd64`.
- Run the primary single-test command.
- Report final size and delta.
Before finalizing:
- Confirm smallest-image objective is still met.
- Document compatibility compromises.
