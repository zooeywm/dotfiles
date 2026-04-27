# Global Codex Guidance

## Core Principles

- Correctness first. Prefer factual, verifiable, minimal changes.
- Give the best practical solution, not a list of weak alternatives.
- Preserve existing architecture, style, naming, and public APIs.
- Do not rewrite unrelated code.
- Do not introduce new dependencies unless clearly necessary.
- If uncertain, state the uncertainty and inspect before changing.

## Language

- Explain to the user in Chinese.
- Use English for code comments, identifiers, commit messages, logs, and technical names unless the project already uses Chinese.

## Workflow

Before editing:
1. Identify the goal and acceptance criteria.
2. Inspect relevant files before making assumptions.
3. Prefer small, reviewable patches.
4. Keep changes inside the current workspace unless explicitly asked.

After editing:
1. Run the smallest relevant verification.
2. Report changed files, verification results, and remaining risks.

## Coding Rules

- Keep code modular and maintainable.
- Prefer stable entry points and isolated implementation details.
- Avoid large files; split new code into modules when it grows too large.
- Do not add silent fallback behavior during development. Fail loudly when a real error must be fixed.
- Never leave empty catch blocks, empty except blocks, or ignored errors.
- Do not swallow errors unless the reason is documented and intentional.
- Do not reinvent standard functionality; use existing project utilities first.
- Do not modify formatting-only across unrelated files.

## Shell / Scripts

- Use `set -euo pipefail` for new Bash scripts.
- Quote variables.
- Use `[[ ... ]]` for Bash pattern matching.
- Prefer explicit checks and clear error messages.
- Avoid destructive commands unless explicitly requested.

## C++ / Qt

- Follow existing Qt idioms and project conventions.
- Preserve signal/slot ownership, QML binding behavior, and object lifetime assumptions.
- Do not replace existing architecture with global state or context properties unless explicitly requested.
- Be careful with Wayland, EGL, VAAPI, DRM, systemd, packaging, and platform-specific logic.

## Rust

- Prefer explicit error handling.
- Avoid unnecessary `clone`, `unwrap`, and `expect`.
- Use `cargo check` as the first verification when Rust code changes.
- Preserve no_std / target / linker assumptions.

## Packaging / System Integration

- Treat install scripts, postinst/postrm, systemd units, udev rules, desktop files, and distro detection as high-risk.
- Do not remove compatibility logic for Debian, Ubuntu, UOS, Kylin, x86_64, arm64, ZhaoXin, E2000Q, RK platforms unless explicitly requested.
- Never install system packages on the host unless explicitly instructed.
- Prefer containerized tooling when a project already provides it.

## Safety

Never run without explicit approval:
- `rm -rf`
- `git reset --hard`
- `git clean -fdx`
- force-push
- package removal
- disk formatting / partition commands
- commands touching production or remote data destructively

Never print secrets, tokens, private keys, or broad environment dumps.

## Verification

Use the smallest relevant check:

- Shell: `bash -n <script>`
- CMake/C++: build the touched target if a build directory exists
- Rust: `cargo check`
- Python: run focused tests or syntax checks
- QML: verify imports, property names, bindings, and ownership assumptions

If verification cannot be run, explain why.

## Done Means

A task is complete only when:

1. The requested behavior is implemented or the question is answered.
2. The change is minimal and localized.
3. Relevant verification was run or the reason is stated.
4. The final response includes:
   - what changed,
   - where it changed,
   - verification result,
   - remaining risk if any.
