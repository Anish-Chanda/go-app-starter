# Golang App Starter Template


Hello :) 
First of all, thank you for checking out this repository. I love working on new ideas, but redoing the same backend setup every single time is rather tedious. This template aims to simplify the process by providing a pre-configured starting point for your Golang projects.

![banner image](https://cdn.statically.io/gh/anish-chanda/anish-chanda/main/assets/go_app_starter_template_banner.webp)

## Getting Started
### Requirements
- Go (1.25+ recommended)
- PostgreSQL (local or via Docker)
- `make` (GNU Make)
- [`hurl`](https://hurl.dev) for API tests
- Docker & Docker Compose (optional, for the dev stack)

> Note: this Makefile has only been tested on a Linux environment so far. I’ll be testing and fixing any macOS/Windows issues soon. (there might be issues due to differences in shell commands and usage of utilities like `awk`, `sed`, etc.)

### Using this template
This repo is marked as a template on GitHub, so the easiest way to start is to click "Use this template" on the GitHub page and create your own repo from it. Once that’s done, the idea is that you’ll run a make setup command (coming soon) that will help you:

- Change the Go module path from github.com/anish-chanda/go-app-starter to your own path
- Update any Flutter bundle IDs / com.example.*-style package names
- Do any other required changes to make it easier for you to get started

### Running the dev stack
0. Clone/Use this repo as a template for your own project.
1. run `cp .env.example .env` and adjust any environment variables as needed.
2. You can use the `make dev-up` command which starts a PostgreSQL container, builds the Golang binary and runs the binary directly.

### Setup helper (coming soon)

I’m planning to add a `make setup` command that will walk you through customising this starter for your own project, for example:

- Updating the Go module name to your own import path
- Adjusting Flutter bundle IDs / com.example.* to match your app
- any other required changes to make it easier for you to get started


## Description & Origin
I started this starter because I enjoy spinning up new ideas, but I wanted a consistent, reusable Go API stack instead of wiring things up differently every time. The backend setup here is a refined version of patterns I’ve used in several of my own projects and have improved over time as I encountered real-world issues/refactors. For the Golang backend and the upcoming Flutter starter, I’m basically modifying a version of what I already use, with a bit more structure and polish, so it’s easier to reuse. I’ve also borrowed ideas from a few solid open-source Go/Flutter projects and documentation along the way, and I’ll continue refining things as I learn what actually works well in practice.


## What’s here right now
Currently, the focus is on providing you with a solid foundation for the backend, including structured logging with HTTP middleware, an authentication layer, PostgreSQL configured with auto-migrations, and API tests written using Hurl.dev. It’s not trying to be an all-in-one solution, but more like a set of standard building blocks you usually want in place before you start writing project-specific business logic or think about shipping to production.

## Current Roadmap
This isn’t a fixed roadmap, more like a rough outline of where I’d like to take this starter over time, I am open to feedback :)

- Backend
    - [x] Structured and HTTP logging
    - [x] Postgresql integration with auto migrations
    - [x] Authentication layer with JWTs
    - [x] API tests with hurl.dev
    - [ ] Password reset flow
    - [ ] Email verification flow for new accounts
    - [ ] Basic roles/permissions support (e.g. user, admin, superadmin)
    - [ ] Middleware for role-based access control
- App (Flutter)
    - [ ] Android, iOS, and Web setup
    - [ ] Linux, macOS, and Windows desktop app setup
    - [ ] Auth flow wired to the backend (login, signup, logout)
    - [ ] Cookie storage and automatically attaching cookies to API requests
    - [ ] Placeholder screens for login, signup, and home (no strong design opinions yet)
- Web (react)
    - [ ] Tooling and core stack: Bun dev tooling, React scaffold, and Tailwind CSS setup
    - [ ] Routing and data layer: TanStack Router + TanStack Query wired to the API
    - [ ] Auth flow (login, signup) wired to the backend
    - [ ] Basic app shell with navigation and a simple home/dashboard placeholder
- Devops
    - [x] GitHub Actions workflow for CI testing (Go unit tests + hurl.dev API tests)
    - [ ] Extend CI to run Flutter tests once the app is in the project
    - [ ] Extend CI to run Web (React) tests once the app is in the project


## Contributing
I’d love for this to evolve based on how people actually use it. For larger feature ideas, we’ll use Discussions and polls to discuss the tradeoffs and determine what the community actually wants before adding more features here. So if you have a feature idea, feel free to open a new issue. For bug fixes, minor improvements, or quality-of-life tweaks, feel free to fork the repo, open a PR, and add a short note explaining the “why” behind the change.

## What this template is not
- A one-size-fits-all setup or “this is the only right way” to build apps.
- A giant bundle of every third‑party service I could cram in.
- A super opinionated UI kit or design system, the frontend side is intentionally light so you can style it how you like.
- A replacement for actually learning Go, React, or Flutter. But it is a good resource to see how some common patterns fit together in practice.

## License
This project is licensed under The Unlicense; see the LICENSE file.md file for complete details.

## Acknowledgments

Inspiration, code snippets, etc.
* [readme-template](https://gist.github.com/DomPizzie/7a5ff55ffa9081f2de27c315f5018afc)
* [hurl-dev](https://hurl.dev)
* [owasp-cheatsheets](https://cheatsheetseries.owasp.org/index.html)