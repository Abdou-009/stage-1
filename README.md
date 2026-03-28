# 🖥️ DevOps Monitoring API — infra-monitor

[![CI Pipeline](https://github.com/Abdou-009/infra-monitor/actions/workflows/ci.yml/badge.svg)](https://github.com/Abdou-009/infra-monitor/actions/workflows/ci.yml)
[![CD Pipeline](https://github.com/Abdou-009/infra-monitor/actions/workflows/cd.yml/badge.svg)](https://github.com/Abdou-009/infra-monitor/actions/workflows/cd.yml)

A **production-ready REST API** for real-time system metrics monitoring — built with Python Flask, containerized with Docker, deployed via CI/CD, and observed with Prometheus + Grafana.

🔗 **Live Demo:** https://devops-lab-i12g.onrender.com

```bash
curl https://devops-lab-i12g.onrender.com/health
curl https://devops-lab-i12g.onrender.com/metrics
```

---

## 📋 Table of Contents

- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [API Endpoints](#-api-endpoints)
- [Monitoring Stack](#-monitoring-stack)
- [CI/CD Pipeline](#-cicd-pipeline)
- [CI/CD Setup Guide](#-cicd-setup-guide)
- [Infrastructure as Code](#-infrastructure-as-code)
- [Testing & Linting](#-testing--linting)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Production Hardening](#-production-hardening)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│              Developer Machine              │
│                                             │
│   git push → GitHub Actions                 │
│                   │                         │
│        ┌──────────┴──────────┐              │
│        │                     │              │
│    CI Pipeline           CD Pipeline        │
│    lint + test           build + push       │
│                          → Docker Hub       │
│                          → Deploy           │
└─────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────┐
│              Production (Render)            │
│                                             │
│   ┌─────────────┐                           │
│   │  Flask API  │ :5000                     │
│   │  (Gunicorn) │                           │
│   └─────────────┘                           │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│         Local Monitoring Stack              │
│                                             │
│   Grafana :3000 → Prometheus :9090          │
│                       │                     │
│               scrapes Flask API :5000       │
│               every 15 seconds              │
└─────────────────────────────────────────────┘
```

---

## ✅ Prerequisites

Make sure you have these installed before starting:

| Tool | Version | Install |
|---|---|---|
| **Docker** | 20.10+ | [docs.docker.com](https://docs.docker.com/get-docker/) |
| **Docker Compose** | 2.0+ | Included with Docker Desktop |
| **Git** | Any | [git-scm.com](https://git-scm.com/) |
| **Python** *(optional, local dev only)* | 3.11+ | [python.org](https://python.org) |

Verify your setup:
```bash
docker --version
docker compose version
git --version
```

---

## 🚀 Quick Start

### Step 1 — Clone the repo

```bash
git clone https://github.com/Abdou-009/infra-monitor.git
cd infra-monitor
```

### Step 2 — Choose your mode

---

#### 🟢 Option A — API Only (simplest, recommended to start)

Runs only the Flask API. Best for testing endpoints and exploring the API.

```bash
docker compose up --build -d
```

| Service | URL |
|---|---|
| Flask API | http://localhost:5000 |
| Health check | http://localhost:5000/health |

Stop it:
```bash
docker compose down
```

---

#### 🔵 Option B — Full Monitoring Stack (API + Prometheus + Grafana)

Runs the complete observability stack. Use this to see dashboards and alerts.

```bash
docker compose -f docker-compose.monitoring.yml up --build -d
```

| Service | URL | Credentials |
|---|---|---|
| Flask API | http://localhost:5000 | — |
| Prometheus | http://localhost:9090 | — |
| Grafana | http://localhost:3000 | admin / admin |

Check all services are running:
```bash
docker compose -f docker-compose.monitoring.yml ps
```

Stop it:
```bash
docker compose -f docker-compose.monitoring.yml down
```

---

#### 🟡 Option C — Local Development (no Docker)

For development without Docker. Runs the raw Python app.

```bash
cd app
pip install -r requirements.txt
python app.py
# → API running at http://localhost:5000
```

> ⚠️ Python 3.11+ required. Use a virtual environment to avoid conflicts:
> ```bash
> python -m venv venv
> source venv/bin/activate   # Linux/Mac
> venv\Scripts\activate      # Windows
> pip install -r requirements.txt
> ```

---

## 📡 API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/` | GET | API overview and available endpoints |
| `/health` | GET | Health check — uptime, version, request count |
| `/metrics` | GET | System metrics — CPU, RAM, disk, network (JSON) |
| `/metrics/prom` | GET | Metrics in Prometheus format (used by Prometheus scraper) |
| `/metrics/prometheus` | GET | Legacy Prometheus format (kept for backward compatibility) |
| `/info` | GET | Server and OS information |
| `/processes` | GET | Top 5 processes by CPU usage |

> ℹ️ **`/metrics/prom` vs `/metrics/prometheus`**: Use `/metrics/prom` — it uses the official `prometheus_client` library. `/metrics/prometheus` is a legacy manual implementation kept for compatibility only.

### Example Responses

**`GET /health`**
```json
{
  "status": "healthy",
  "version": "1.2.0",
  "timestamp": "2026-03-13T15:50:00.000000",
  "uptime_seconds": 3842.17,
  "requests_served": 128
}
```

**`GET /metrics`**
```json
{
  "cpu_percent": 12.5,
  "cpu_count": 4,
  "memory": {
    "total_gb": 30.65,
    "used_gb": 12.82,
    "available_gb": 17.83,
    "percent": 41.8
  },
  "disk": {
    "total_gb": 386.43,
    "used_gb": 318.26,
    "free_gb": 68.17,
    "percent": 82.4
  },
  "network": {
    "bytes_sent": 1048576,
    "bytes_recv": 2097152
  }
}
```

---

## 📊 Monitoring Stack

```
┌─────────────┐
│   Grafana   │ ← Dashboards & Alerts      :3000
└──────┬──────┘
       │ queries
┌──────▼──────┐
│ Prometheus  │ ← Scrapes metrics every 15s  :9090
└──────┬──────┘
       │ scrapes /metrics/prom
┌──────▼──────┐
│  Flask API  │ ← Your application           :5000
└─────────────┘
```

### Grafana Dashboard

Pre-built dashboard with 8 panels — auto-provisioned on startup, no manual import needed:

- CPU usage %
- Memory usage %
- Disk usage %
- Uptime
- Request count
- Request latency percentiles (p50, p95, p99)

📸 Screenshots in [`docs/images/`](docs/images/)

### Alerting Rules

| Alert | Condition | Duration |
|---|---|---|
| 🟡 HighCPU | CPU > 80% | 2 min |
| 🟡 HighMemory | Memory > 85% | 2 min |
| 🔴 APIDown | Target unreachable | 1 min |
| 🟡 HighDiskUsage | Disk > 90% | 5 min |

---

## 🔄 CI/CD Pipeline

Every `git push` to `main` triggers two automated pipelines:

```
git push → GitHub Actions
               │
    ┌──────────┴──────────┐
    │                      │
CI Pipeline            CD Pipeline
    │                      │
✅ Lint (flake8)       📦 Build Docker image
✅ Test (pytest)       📤 Push to Docker Hub
✅ Docker build        🚀 Deploy to Render
```

The CD pipeline only runs if CI passes — broken code is never deployed.

---

## ⚙️ CI/CD Setup Guide

To run the CI/CD pipeline on your own fork, you need to configure 3 GitHub Secrets.

### Step 1 — Docker Hub token

1. Go to [hub.docker.com](https://hub.docker.com) → Account Settings → Security
2. Click **"New Access Token"** → name it `github-actions` → copy the token

### Step 2 — Render deploy hook

1. Go to your Render service → Settings → **Deploy Hook**
2. Copy the URL

### Step 3 — Add secrets to GitHub

Go to your repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Token from Step 1 |
| `RENDER_DEPLOY_HOOK` | URL from Step 2 |

Once added, push any commit to `main` and watch the Actions tab.

---

## 🏗️ Infrastructure as Code

The Terraform configuration in `terraform/` defines the Render deployment as code.

```bash
cd terraform
terraform init
terraform plan   # preview what would be created
```

> ℹ️ `terraform apply` requires a **paid Render plan** (Starter or above) to use the Render API for deployment. The free tier only supports manual or webhook-based deploys. The `terraform plan` command works on free tier and validates the IaC configuration.
>
> GCP deployment via Terraform is planned for a future release.

---

## 🧪 Testing & Linting

```bash
# Install dev dependencies
pip install pytest flake8

# Run linter
flake8 app/ tests/

# Run all tests (17 tests)
pytest tests/ -v

# Run a specific test
pytest tests/test_app.py::test_health -v
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **Python 3.11** | Application runtime |
| **Flask** | REST API framework |
| **psutil** | System metrics collection |
| **prometheus_client** | Official Prometheus SDK |
| **Gunicorn** | Production WSGI server |
| **Docker** | Containerization |
| **Docker Compose** | Multi-container orchestration |
| **Prometheus** | Metrics collection & alerting |
| **Grafana** | Dashboards & visualization |
| **GitHub Actions** | CI/CD automation |
| **Docker Hub** | Container registry |
| **Render** | Cloud deployment |
| **Terraform** | Infrastructure as Code |

---

## 📁 Project Structure

```
infra-monitor/
├── .github/
│   └── workflows/
│       ├── ci.yml                          # CI — lint, test, Docker build
│       └── cd.yml                          # CD — push to Docker Hub, deploy to Render
├── app/
│   ├── app.py                              # Flask API + Prometheus metrics
│   └── requirements.txt                    # Pinned Python dependencies
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml                  # Scrape config (targets + intervals)
│   │   └── alerting_rules.yml              # Alert rules (CPU, RAM, disk, API down)
│   └── grafana/
│       ├── dashboards/
│       │   └── dashboard.json              # Pre-built dashboard (8 panels)
│       └── provisioning/
│           ├── datasources/
│           │   └── datasource.yml          # Auto-provision Prometheus data source
│           └── dashboards/
│               └── dashboard-provider.yml  # Auto-provision dashboard on startup
├── terraform/
│   ├── main.tf                             # Render web service resource
│   ├── variables.tf                        # Input variables
│   ├── outputs.tf                          # Output values (URL, service ID)
│   └── providers.tf                        # Render provider config
├── tests/
│   └── test_app.py                         # Unit tests (pytest) — 17 tests
├── docs/
│   └── images/                             # Screenshots for README
├── .flake8                                 # Linter configuration
├── Dockerfile                              # Multi-stage, non-root, with healthcheck
├── docker-compose.yml                      # API only
├── docker-compose.monitoring.yml           # Full stack (API + Prometheus + Grafana)
├── .dockerignore
└── README.md
```

---

## 🔒 Production Hardening

- ✅ Non-root container user
- ✅ Gunicorn WSGI server (not Flask dev server)
- ✅ Docker health checks
- ✅ Resource limits (CPU & memory)
- ✅ Structured JSON logging
- ✅ Error handling on all endpoints
- ✅ Prometheus metrics via official library
- ✅ Grafana dashboards with alerting rules
- ✅ Pinned dependency versions
- ✅ Automated CI/CD pipeline
- ✅ Linting enforced on every push
- ✅ CD pipeline blocked if CI fails

---

## 🌐 Live Demo

🔗 **https://devops-lab-i12g.onrender.com**

> ⚠️ Hosted on Render free tier — may take 30–60 seconds to wake up on first request.

```bash
curl https://devops-lab-i12g.onrender.com/health
curl https://devops-lab-i12g.onrender.com/metrics
curl https://devops-lab-i12g.onrender.com/info
curl https://devops-lab-i12g.onrender.com/processes
```
