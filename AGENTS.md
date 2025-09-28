# Agent Instructions

- After completing any task that modifies code, run `rake ci` before finalizing changes.
- Follow the instruction hierarchy: system instructions first, then developer, user, and finally this file.
- Commit changes with clear messages and prepare to describe modifications for the next prompt.
- The repository's Markdown specification is documented in `specifications/lenex-v3.md`.

# Coding Guidelines for dsv7-parser

Concise conventions for contributing code and tests to this repo. Focus is on a small, dependency-light Ruby library with a streaming validator and Minitest suite.

- Add `# frozen_string_literal: true` to the top of Ruby files.
- Avoid non-portable syntax not available in Ruby 2.7.

## Style & Linting

- Use RuboCop; run `bundle exec rake rubocop`.
- Write both library code and tests in a RuboCop-compliant way; fix all offenses before submitting.
- Do not change `.rubocop.yml` to satisfy offenses; fix the code instead.
- Avoid inline `# rubocop:disable` comments; refactor to comply where possible.

- Keep methods small and cohesive; favor clear names over brevity.
- Names: prefer full words for variables and methods; avoid abbreviations (e.g., use `line_number` not `line_no`, `add_error` not `add_err`).

- Keep responsibilities narrow; prefer small classes/modules over large monoliths.

## Errors, Warnings, Messages

- Use precise, user-actionable wording; match existing phrasing where possible.

## IO & Encoding

- Stream inputs (avoid loading entire files); set `io.binmode`.

## Performance & Memory

- Use streaming and incremental processing wherever possible (enumerate by line).
- Optimize for low memory usage (avoid reading whole files or accumulating large arrays).
- Prefer single-pass algorithms; keep per-line state minimal and discard intermediate buffers.

## Finish Checklist

- Run tests: `rake test` (or `bundle exec rake test`).
- Auto-correct style: `rubocop -A .` (or `bundle exec rubocop -A .`).
- Fix any remaining RuboCop items; re-run `rake test` and `rubocop` until green.
- If you add a new feature or public API, update `README.md` with usage and examples.

## Patch Discipline

- Keep diffs minimal and targeted; avoid unrelated refactors.
- Do not reformat whole files; only touch necessary lines.
- Don’t add license headers or banners.
- Avoid inline code comments unless explicitly requested.
- Use descriptive names; avoid one-letter variables.
- Prefer full-length, intent-revealing variable names; avoid abbreviations (e.g., `line_number` not `line_no`).

## Dependency Policy

- Keep runtime dependencies at zero; prefer stdlib.
- Discuss before adding any new gem (including dev-only).
- Maintain streaming design and dependency-light footprint.
