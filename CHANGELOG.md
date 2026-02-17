# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.0.0] — 2026-02-16

### Added
- **BMAD Planning Agents** — 4 new agents for agile planning workflow:
  - `analyst` (Haiku) — interviews user, produces `docs/briefs/product-brief.md`
  - `pm` (Haiku) — transforms brief into PRD at `docs/prd.md`
  - `architect` (Sonnet) — designs technical architecture at `docs/architecture.md`
  - `scrum-master` (Haiku) — breaks PRD into implementation-ready stories at `docs/stories/*.md`
- `/project-help` command — lists all agents, hooks, workflows, and manual lint instructions
- `docs/README.md` — BMAD workflow guide and directory structure scaffolding

### Removed
- **Stop hook** — end-of-turn `tsc`/`eslint`/`ruff` checks removed (caused high CPU and 5+ minute hangs). The `end-of-turn-check.sh` script is still available for manual use.

### Changed
- Agent count: 5 → 9 (4 BMAD planning + 5 quality gates)
- Bootstrap step count: 10 → 12
- Workflow updated: `Plan (BMAD agents) → Develop → review → qa → ship`
- Version bumped to 2.0.0

## [Unreleased]

### Added
- Multi-platform scaffolding via `--agent-platform` (`claude`, `gemini`, `codex`, `auto`)
- Gemini project command scaffold: `.gemini/commands/project-help.toml`
- Codex skill scaffold: `.agents/skills/project-help/SKILL.md`
- Provider help docs in `docs/help/` (`claude.md`, `gemini.md`, `codex.md`)
- Optional Gemini experimental subagent scaffold via `--enable-experimental-subagents`
- Auto-routing workflow with Quick Fix / Build / Project tiers
- Architect agent for tech decision docs
- Doc-sync agent for keeping planning docs current
- Planning rules with tier detection and plain-language question bank
- Templates for product briefs, tech decisions, and changelog entries
- `docs/` directory for generated planning artifacts (gitignored)

### Changed
- Bootstrap script summary, uninstall cleanup, and `.gitignore` handling are now provider-aware
- `/project-help` behavior documented per active product (Claude/Gemini) plus Codex `$project-help`
