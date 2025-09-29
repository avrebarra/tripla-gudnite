
# Gudnite API

Gudnite is a social sleep-tracking backend API, designed for easy sleep session logging and social engagement. For a detailed plan and technical breakdown, see [`docs/DRAFT.md`](docs/DRAFT.md).

## Key Features
- **Sleep Tracking:** Clock in/out, view your sleep history
- **Social Connections:** Follow/unfollow users, see friends’ sleep records
- **Feed:** See a weekly leaderboard of friends’ sleep durations

## Project Highlights
- **Dev Container:**
	- Ready-to-code with `.devcontainer` for consistent development environments (see `.devcontainer/devcontainer.json`).
- **API Documentation:**
	- Interactive Swagger UI at [`/docs`](http://localhost:4994/docs) (auto-generated with Rswag)
- **Makefile Commands:**
	- `make start` — Start Rails server
	- `make migrate` — Run DB migrations
	- `make generate-apidoc` — Generate Swagger docs
	- `make test` — Run RSpec test suite
	- `make lint` — Auto-correct with Rubocop
	- `make seed` — Seed the database
- **Docs & Planning:**
	- Main planning and technical details: [`docs/DRAFT.md`](docs/DRAFT.md)
	- All documentation: [`docs/`](docs/)
- **AI Usage:**
	- This repo leverages AI for code generation and planning. See commit messages and PR descriptions on GitHub for context and explanations.

## Quick Start
1. Clone the repo and open in VS Code (with Dev Containers enabled)
2. Run `make start` to launch the Rails server
3. Visit [`/docs`](http://localhost:4994/docs) for API exploration

## API Endpoints (Sample)
- `POST /sleep_records/clock_in` — Start sleep session
- `POST /sleep_records/clock_out` — End sleep session
- `GET /sleep_records` — List your sleep records
- `POST /followings` — Follow a user
- `DELETE /followings/:id` — Unfollow a user
- `GET /friends/sleep_feed` — Friends’ weekly sleep leaderboard

All endpoints require token-based authentication.

## More Info
- See [`docs/DRAFT.md`](docs/DRAFT.md) for:
	- Data models
	- Sequence diagrams
	- Query plans
	- Design decisions

