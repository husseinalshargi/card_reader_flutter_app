# Business Card Reader

A Flutter mobile app that scans business cards and saves the contact details, backed by a Dockerized FastAPI service that does the image processing and AI extraction. Pushing to `main` builds the backend image and redeploys it to AWS EC2 automatically.

<p align="center">
  <img src="docs/screenshot_1.png" width="260"> <img src="docs/screenshot_2.png" width="260">
</p>

## What it does

1. The user signs in (Firebase Auth, Google or Facebook) and photographs a card, front and back if needed.
2. The app sends the image(s) to `POST /process_card` with the Firebase ID token.
3. The backend verifies the token, applies a per-user rate limit (3 requests per minute, tracked in Redis), preprocesses the images with OpenCV, and extracts the card fields as JSON: full name, phone, email, company, website, address. Extraction has two interchangeable engines: OCR (EasyOCR + a local LLM through Ollama) and Gemini Flash. Gemini Flash is the default because it answers in about a second with no GPU.
4. The user reviews the result and saves it. Cards are stored in MySQL and can be listed, edited, deleted, shared, or added straight to the phone's contacts.

## Architecture

```
Flutter app ──(JWT + images)──▶ FastAPI ──▶ OpenCV preprocessing ──▶ extraction engine
                                                                    ├── Gemini Flash (default)
                                                                    └── EasyOCR + Ollama LLM (kept, switchable)
                                  │
                                  ├── Firebase Admin (token verification)
                                  ├── Redis (rate limiting)
                                  └── MySQL via SQLAlchemy (saved cards)
```

## Stack

| Layer | Tech |
| --- | --- |
| Mobile | Flutter, Riverpod, Firebase Auth, image_picker, flutter_contacts, share_plus |
| API | Python 3.12, FastAPI, Uvicorn, Pydantic |
| Image processing | OpenCV (headless), imutils |
| Extraction | Gemini Flash via `google-genai` (default), EasyOCR + Ollama via LangChain (`services/old_ai_service.py`) |
| Data | MySQL 8 (SQLAlchemy + PyMySQL), Redis |
| Auth | Firebase Admin SDK |
| Infra | Docker, Docker Compose, GitHub Actions, Docker Hub, AWS EC2 |

## Backend endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/process_card` | Upload 1 or 2 images (max 5 MB each), get extracted fields |
| POST | `/upsert_card` | Create or update a saved card |
| POST | `/get_card` | Get one card by id |
| GET | `/get_all_cards` | List the user's cards |
| POST | `/delete_card` | Delete a card |

Every endpoint requires a valid Firebase ID token in the request header.

## Run locally

Backend:

```bash
cd reader_back_end
cp .env.example .env        # fill in the values below
docker compose up --build   # API on http://localhost:8000, MySQL on 3306
```

`.env` keys:

```
GEMINI_API_KEY=
FIREBASE_CRED_PATH=firebase_sdk_cred/<service-account>.json
REDIS_HOST=
REDIS_PORT=
REDIS_PASSWORD=
mysql_url=mysql+pymysql://root:<password>@db:3306/<database>
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=
```

Mobile app:

```bash
cd card_reader_app
flutter pub get
flutter run
```

Point the app at your backend URL in its `.env` (loaded by `flutter_dotenv`).

## CI/CD

`.github/workflows/docker-image_CICD.yml` runs on every push to `main` that touches `reader_back_end/`:

1. **Build**: builds the backend image and pushes it to Docker Hub.
2. **Deploy**: copies `docker-compose-prod.yml` to the EC2 host over SSH, pulls the new image with a read-only token, and runs `docker compose up -d --force-recreate`. Production config and the Firebase credential file live on the server, not in the repo.

Required GitHub secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `DOCKERHUB_READ_ONLY_TOKEN`, `EC2_HOST`, `EC2_USERNAME`, `EC2_PRIVATE_KEY`.

## Project layout

```
card_reader_app/        Flutter client (lib/Screens, lib/Services, lib/Widgets, lib/Data)
reader_back_end/
  main.py               FastAPI app and endpoints
  services/             image_pre_processor.py, ai_service.py, card_reader.py
  database_connections/ redis_db.py, firebase_db.py
  db/                   SQLAlchemy models, schemas, repositories
  settings/config.py    env-driven config
  Dockerfile, docker-compose.yml, docker-compose-prod.yml
.github/workflows/      CI/CD pipeline
```

## Notes

- Logs are written per day to `Logs/` inside the container and persisted with a Docker volume.
- Both extraction engines are in the repo. `services/ai_service.py` calls Gemini Flash, `services/old_ai_service.py` runs EasyOCR and feeds the text to a local LLM through Ollama and LangChain. The OCR version works but needs a GPU server and takes longer per card, so Gemini Flash is wired in for instant results. To switch back, change the import in `services/card_reader.py` and uncomment the OCR and LLM packages in `requirements.txt`.
