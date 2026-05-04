# docker-dbms

This repository contains:

- `postgres/`: Postgres + pgAdmin via Docker Compose
- `youtube-ai-crawler/`: Go tools to export YouTube videos to CSV and import the CSV into Postgres

## Prerequisites

- Docker + Docker Compose
- Go (tested with Go 1.26.2 per `youtube-ai-crawler/go.mod`)
- Python 3 + `uv` (optional, only for downloading external datasets)

## Quick start

### 1) Clone the repo

```bash
git clone https://github.com/LqTan/youtube-data-crawler.git
cd docker-dbms
```

### 2) Configure environment variables

Create `.env` files from the examples:

```bash
cp postgres/.env.example postgres/.env
cp youtube-ai-crawler/.env.example youtube-ai-crawler/.env
```

Then update these variables as needed:

- `postgres/.env`
  - `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`
  - `PGADMIN_EMAIL`, `PGADMIN_PASSWORD`, `PGADMIN_PORT`
- `youtube-ai-crawler/.env`
  - `YOUTUBE_API_KEY` (required)
  - `TARGET_VIDEO_COUNT`, `SEARCH_PAGES_PER_QUERY`, `OUTPUT_CSV`
  - `DB_HOST`, `INPUT_CSV`
  - `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`

### 3) Start Postgres + pgAdmin

```bash
cd postgres
docker compose up -d
```

Check container status:

```bash
docker compose ps
```

### 4) Export YouTube -> CSV

```bash
cd ../youtube-ai-crawler
go run ./cmd/export-youtube-csv
```

By default, the CSV is generated at `youtube-ai-crawler/data/youtube_ai_videos.csv` (via `OUTPUT_CSV`).

### 5) (Optional) Download external datasets (Python)

This repo includes helper scripts to download external datasets into `youtube-ai-crawler/data/external/`:

```bash
cd ../youtube-ai-crawler
uv run python scripts/download_kaggle_aiml_youtube.py
uv run python scripts/download_hf_channel_metadata.py
uv run python scripts/download_hf_youtube_transcriptions.py
```

### 6) Merge datasets

Merge the base CSV with all external CSV files under `EXTERNAL_DIR` (recursively):

```bash
cd ../youtube-ai-crawler
go run ./cmd/merge-datasets
```

Outputs:

- `data/external/merged_youtube_ai_videos.csv`: base + merged records
- `data/external/manual_review.csv`: records that need manual review or enrichment

### 7) Import CSV -> Postgres

```bash
cd ../youtube-ai-crawler
go run ./cmd/import-csv-postgres
```

The importer loads `.env` from `youtube-ai-crawler/` and also tries to load `../postgres/.env`, so make sure `POSTGRES_*` matches your running Postgres instance.

## Notes

- CSV outputs in `youtube-ai-crawler/data/*.csv` are ignored by `.gitignore`.
- To open pgAdmin: `http://localhost:${PGADMIN_PORT}` and log in with `${PGADMIN_EMAIL}` / `${PGADMIN_PASSWORD}`.
