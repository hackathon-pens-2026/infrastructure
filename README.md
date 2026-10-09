# Infrastructure & DevOps Deployment Hub

All infrastructure, containerization, environment templates, and cloud deployment configs are centralized in this `infrastructure/` directory.

> **Note for Collaborators**:
> The `backend/` and `frontend/` directories are left clean so your team can initialize their respective codebases (`dotnet new webapi`, `create-next-app`, etc.) without any file conflicts. Once initialized, simply reference or copy the corresponding configurations from here.

---

## 📁 Centralized Infrastructure Structure

```text
infrastructure/
├── README.md                          # Full guide & architecture documentation
├── docker/
│   ├── Dockerfile.backend             # Multi-stage production Dockerfile (.NET 8)
│   ├── Dockerfile.frontend            # Multi-stage production Dockerfile (Next.js)
│   ├── .dockerignore                  # Docker build ignore rules
│   └── docker-compose.yml             # Full-stack local dev (PostgreSQL + Backend + Frontend)
├── railway/
│   ├── railway.json                   # Railway Docker deployment config
│   └── railway.toml                   # Railway TOML deployment config
├── render/
│   └── render.yaml                    # Render Blueprint (Web Service + Managed PostgreSQL)
├── azure/
│   ├── main.bicep                     # Azure App Service on Linux (Bicep IaC)
│   └── deploy-azure.sh                # Azure CLI deployment script
├── vercel/
│   └── vercel.json                    # Vercel Next.js configuration & security headers
├── env/
│   ├── appsettings.Development.json   # .NET 8 dev configuration template
│   ├── backend.env.example            # Backend environment variables template
│   └── frontend.env.example           # Next.js frontend environment variables template
└── github-workflows/
    ├── backend-ci.yml                 # .NET 8 CI (build, test)
    ├── frontend-ci.yml                # Next.js CI (lint, build)
    └── docker-build-check.yml         # Container build verification
```

---

## 1. Multi-Stage Dockerfile for .NET 8 (`infrastructure/docker/Dockerfile.backend`)

Optimized for small image size, fast caching, and hardened security:
- **Runtime base**: `mcr.microsoft.com/dotnet/aspnet:8.0` (chiseled/minimal Linux).
- **SDK build**: `mcr.microsoft.com/dotnet/sdk:8.0`.
- **Caching**: Restores `*.csproj` independently prior to source copying.
- **Security**: Runs under non-root user `app` (standard in .NET 8).
- **Port**: Bound to container port `8080` (`ASPNETCORE_URLS=http://+:8080`).

### Build & Run Commands:
```bash
# Build from project root pointing to backend folder:
docker build -f infrastructure/docker/Dockerfile.backend -t backend-api:latest ./backend

# Run container locally:
docker run -d -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Development \
  backend-api:latest
```

*(Optional: Once your teammate initializes `backend/`, you can also copy `Dockerfile.backend` to `backend/Dockerfile` if preferred).*

---

## 2. GitHub Repo Monorepo Setup

The root repository contains:
- Root `.gitignore` configured for both .NET and Node.js artifacts.
- CI/CD workflows under `.github/workflows/` (mirrored in `infrastructure/github-workflows/`).

### How CI handles monorepo changes:
- Changes to `backend/**` trigger `.github/workflows/backend-ci.yml`.
- Changes to `frontend/**` trigger `.github/workflows/frontend-ci.yml`.

---

## 3. Vercel Configuration for Next.js (`infrastructure/vercel/vercel.json`)

Vercel natively supports Next.js in a monorepo:
1. Connect your repository to **Vercel**.
2. In Project Settings:
   - **Framework Preset**: `Next.js`
   - **Root Directory**: Set to `frontend`
3. Add Environment Variable:
   - `NEXT_PUBLIC_API_URL`: Your deployed backend URL (e.g., `https://backend.up.railway.app`)
4. *(Optional)* Copy `infrastructure/vercel/vercel.json` to `frontend/vercel.json` if custom headers or rewrite proxies are needed.

---

## 4. Cloud Deployments for .NET Backend

### Option A: Railway
- File: `infrastructure/railway/railway.json`
- In Railway Dashboard:
  - Add service from GitHub repo.
  - Set **Root Directory** to `/backend`.
  - Set **Dockerfile Path** to `../infrastructure/docker/Dockerfile.backend` (or copy Dockerfile to `backend/Dockerfile`).
  - Set Environment Variables:
    - `PORT`: `8080`
    - `ASPNETCORE_URLS`: `http://+:8080`
    - `ASPNETCORE_ENVIRONMENT`: `Production`

### Option B: Render
- File: `infrastructure/render/render.yaml`
- In Render Dashboard:
  - Create **New Blueprint Instance** and point to this repo.
  - Render will auto-provision the web service and a managed PostgreSQL database.

### Option C: Azure App Service (Linux Containers)
- Files: `infrastructure/azure/main.bicep` and `infrastructure/azure/deploy-azure.sh`
- Deploy with Azure CLI:
  ```bash
  az login
  bash ./infrastructure/azure/deploy-azure.sh
  ```
  Sets `WEBSITES_PORT=8080` and `ASPNETCORE_URLS=http://+:8080`.

---

## 5. Configurations & Environment Templates (`infrastructure/env/`)

| File | Purpose | When Teammate Finishes Init |
|---|---|---|
| `appsettings.Development.json` | Logging, Postgres ConnectionString, JWT, and CORS for Next.js (`http://localhost:3000`) | Copy or merge into `backend/appsettings.Development.json` |
| `backend.env.example` | ASP.NET Core environment variable overrides (`ConnectionStrings__DefaultConnection`, `Jwt__SecretKey`) | Copy to `backend/.env.example` or import to Cloud Dashboard |
| `frontend.env.example` | Next.js API endpoint `NEXT_PUBLIC_API_URL` | Copy to `frontend/.env.example` |

---

## 6. Local Development via Docker Compose

Spin up PostgreSQL, .NET Backend, and Next.js frontend with:
```bash
docker compose -f infrastructure/docker/docker-compose.yml up --build -d
```
- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:8080`
- PostgreSQL: `localhost:5434`
