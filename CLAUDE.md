# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

OphidIA (repo name `snakes_of_imt`) is an academic capstone project: a cross-platform Flutter mobile app that
classifies Brazilian snake species (currently scoped to genus *Bothrops*) from a photo, using a PyTorch/EfficientNet-B3
model served over a separate FastAPI backend. The app also shows species info (venom type, antivenom) and a map of
nearby sighting records via Google Maps.

The repo contains three loosely-coupled parts:
- **`lib/`** — the Flutter/Dart app (this is the main thing Claude Code will be asked to edit).
- **`lib/models/*.py`** — the standalone FastAPI inference server + PyTorch training/eval scripts (not part of the
  Flutter build; run separately with Python).
- **`lib/scripts/*.py`** — a one-off ETL pipeline for populating the Supabase `snakes` table from GBIF data (see
  `lib/scripts/README.md` for the 3-step fetch → enrich → insert flow).

## Commands

Flutter/Dart (run from repo root):
```bash
flutter pub get              # install dependencies
flutter run                  # run the app on a connected device/emulator
flutter analyze              # static analysis (flutter_lints)
flutter test                 # run all tests
flutter test test/widget_test.dart   # run a single test file
```
Note: `test/widget_test.dart` is still the default Flutter counter-app template and does not test this app's actual
widgets — don't treat it as a meaningful example of test coverage or app behavior.

Python inference backend (`lib/models/`, run from that directory):
```bash
cd lib/models
python main.py                # not directly runnable; serve with uvicorn, e.g.:
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
The server loads `classes.json` and `best_model_b3_v2.pth` from the current working directory, so it must be started
from inside `lib/models/`. It exposes a single `POST /predict` endpoint (multipart image upload) returning
`{snake_id, specie, confidence}`.

Python Supabase-population pipeline (`lib/scripts/`):
```bash
cd lib/scripts
pip install -r requirements.txt
python fetch_gbif.py <Genus>
python enrich.py <Genus>
python insert_supabase.py <Genus>   # keep dry_run=True in the script until data is reviewed
```

## Architecture

**Screens** (`lib/screens/`) are simple `StatefulWidget`/`StatelessWidget` pages, barrel-exported through
`screens.dart` (which also re-exports `package:flutter/material.dart`, so screen files only need
`import 'screens.dart';`). Navigation is straightforward `Navigator.push`/bottom-nav index switching, not a router
package. `home.dart` hosts the Google Map + nearby-sightings view; `camera.dart` handles capture/upload and calls the
inference service; `snake_information.dart` renders a `SnakeModel` fetched from Supabase.

**Services** (`lib/services/`) wrap all external I/O and are barrel-exported through `services.dart`. Each service is
a thin class around a single `Supabase.instance.client` or `http` call — no shared base class or DI container:
- `AuthService` — Supabase Auth (signup/login), including password-strength validation and Portuguese-language error
  mapping for known Supabase auth error messages.
- `StorageService` / `UploadService` — both upload images to the Supabase `user-history` storage bucket and return an
  `UploadResult`; they are near-duplicates (one returns a signed URL scoped to the current user, the other a public
  URL under a shared `uploads/` path) — check which one a call site actually needs before assuming they're
  interchangeable or before consolidating them.
- `SnakeInformationService` — fetches a `SnakeModel` row from the Supabase `snakes` table by id.
- `IbgeService` — looks up Brazilian municipalities by state (UF) from the public IBGE API, used in the registration
  city/state picker.
- `IAService` (in `agent_service.dart`) — calls the FastAPI `/predict` endpoint with a captured/picked image file.
  **`baseUrl` is a hardcoded local IP/placeholder** ("colocar ip aqui") — it must point at wherever `lib/models`'
  FastAPI server is actually running (same LAN IP:8000 during development), so update it when the inference server's
  host changes. This file currently has an **unresolved git merge conflict** (`<<<<<<< Updated upstream` /
  `>>>>>>> Stashed changes` around the `baseUrl` value) — resolve it before relying on this service.

**Models** (`lib/models/*.dart`) are plain Dart data classes with a `fromMap` factory matching the Supabase table
schema (snake_case keys from Postgres mapped to Dart fields), e.g. `SnakeModel`, `UploadResult`. Don't confuse these
with the Python files that also live under `lib/models/` — the `.dart` and `.py` files in that directory are
unrelated (Dart data models vs. the PyTorch training/inference code); it's a naming collision, not a shared module.

**Localization**: `easy_localization` with `assets/translations/{en-US,pt-BR}.json`, default/fallback locale is
`pt-BR` (set in `lib/main.dart`). Wrap new user-facing strings with `.tr()` and add keys to both translation files
rather than hardcoding Portuguese or English text — though most existing UI strings are still hardcoded Portuguese
and haven't been migrated yet.

**Backend**: Supabase (Postgres + Auth + Storage) is initialized once in `lib/main.dart` with a hardcoded project URL
and anon key, then accessed everywhere via `Supabase.instance.client`. Relevant tables/buckets: `snakes` (species
info), `user-history` (storage bucket for uploaded photos). The FastAPI/PyTorch inference server is a separate
process from Supabase and is not deployed anywhere — it's expected to be run locally/on a LAN host during
development.
