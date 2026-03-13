# 🖥️ DevOps Monitoring API

![CI Pipeline](https://github.com/abdou-009/DevOps_Project/actions/workflows/ci.yml/badge.svg)
![CD Pipeline](https://github.com/abdou-009/DevOps_Project/actions/workflows/cd.yml/badge.svg)

A **production-ready REST API** for real-time system metrics monitoring, built with Python Flask, containerized with Docker, and deployed via **CI/CD pipeline** — with full **Prometheus + Grafana observability**.

> Part of a **6-stage DevOps platform** demonstrating the full software delivery lifecycle — from containerization to GitOps.

---

## 📊 Monitoring Stack (Stage 3)

A complete **observability stack** runs alongside the API:

```
                          ┌─────────────┐
                          │  Grafana    │ ← Dashboards & Alerts
                          │  :3000      │
                          └──────┬──────┘
                                 │ queries
                          ┌──────▼──────┐
                          │ Prometheus  │ ← Scrapes metrics every 15s
                          │  :9090      │
                          └──────┬──────┘
                                 │ scrapes /metrics/prom
                          ┌──────▼──────┐
                          │  Flask API  │ ← Your application
                          │  :5000      │
                          └─────────────┘
```

### What You Get

| Component      | URL                    | Purpose                                  |
| -------------- | ---------------------- | ---------------------------------------- |
| **Flask API**  | `http://localhost:5000` | REST API with system metrics             |
| **Prometheus** | `http://localhost:9090` | Metrics collection & alerting rules      |
| **Grafana**    | `http://localhost:3000` | Pre-built dashboard (login: admin/admin) |

### Alerting Rules

| Alert            | Condition              | Duration |
| ---------------- | ---------------------- | -------- |
| 🟡 HighCPU      | CPU > 80%              | 2 min    |
| 🟡 HighMemory   | Memory > 85%           | 2 min    |
| 🔴 APIDown      | Target unreachable     | 1 min    |
| 🟡 HighDiskUsage | Disk > 90%            | 5 min    |

### Quick Start — Monitoring Stack

```bash
# Start everything (API + Prometheus + Grafana)
docker-compose -f docker-compose.monitoring.yml up --build -d

# Check all services are running
docker-compose -f docker-compose.monitoring.yml ps

# Open Grafana → http://localhost:3000 (admin/admin)
# Open Prometheus → http://localhost:9090/targets

# Stop everything
docker-compose -f docker-compose.monitoring.yml down
```

---

## 🔄 CI/CD Pipeline (Stage 2)

Every `git push` to `main` triggers an **automated pipeline**:

```
git push ──→ GitHub Actions
                 │
      ┌──────────┴──────────┐
      │                      │
  CI Pipeline            CD Pipeline
      │                      │
  ✅ Lint (flake8)       📦 Build Docker image
  ✅ Test (pytest)       📤 Push to Docker Hub
  ✅ Docker build        🚀 Deploy to Render
```

### Required GitHub Secrets

| Secret               | Purpose                  |
| -------------------- | ------------------------ |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN`    | Docker Hub access token  |
| `RENDER_DEPLOY_HOOK` | Render deploy hook URL   |

---

## 📡 API Endpoints

| Endpoint              | Method | Description                                       |
| --------------------- | ------ | ------------------------------------------------- |
| `/`                   | GET    | API overview & available endpoints                |
| `/health`             | GET    | Health check with uptime & request count          |
| `/metrics`            | GET    | CPU, RAM, disk & network metrics (JSON)           |
| `/metrics/prometheus` | GET    | Metrics in Prometheus text format (legacy)        |
| `/metrics/prom`       | GET    | Metrics via official `prometheus_client` library  |
| `/info`               | GET    | Server & OS information                           |
| `/processes`          | GET    | Top 5 processes by CPU usage                      |

### Example Responses

<details>
<summary><code>GET /health</code></summary>

```json
{
  "status": "healthy",
  "version": "1.2.0",
  "timestamp": "2026-03-13T15:50:00.000000",
  "uptime_seconds": 3842.17,
  "requests_served": 128
}
```
</details>

<details>
<summary><code>GET /metrics</code></summary>

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
</details>

---

## 🚀 Quick Start

### Docker (Recommended)

```bash
docker-compose up --build
```

The API will be available at `http://localhost:5000`

### Local Development

```bash
cd app
pip install -r requirements.txt
python app.py
```

---

## 🧪 Testing & Linting

```bash
# Install dev tools
pip install pytest flake8

# Run linter
flake8 app/ tests/

# Run tests (17 tests)
pytest tests/ -v
```

---

## 🛠️ Tech Stack

| Tool                  | Purpose                       |
| --------------------- | ----------------------------- |
| **Python 3.11**       | Application runtime           |
| **Flask**             | REST API framework            |
| **psutil**            | System metrics collection     |
| **prometheus_client** | Official Prometheus SDK       |
| **Gunicorn**          | Production WSGI server        |
| **Docker**            | Containerization              |
| **Prometheus**        | Metrics collection & alerting |
| **Grafana**           | Dashboards & visualization    |
| **GitHub Actions**    | CI/CD automation              |
| **Docker Hub**        | Container registry            |
| **Render**            | Cloud deployment              |

---

## 📁 Project Structure

```
DevOps_Project/
├── .github/
│   └── workflows/
│       ├── ci.yml                          # CI — lint, test, Docker build
│       └── cd.yml                          # CD — push to Docker Hub, deploy
├── app/
│   ├── app.py                              # Flask API + Prometheus metrics
│   └── requirements.txt                    # Pinned Python dependencies
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml                  # Prometheus scrape config
│   │   └── alerting_rules.yml              # Alert rules (CPU, RAM, disk, API)
│   └── grafana/
│       ├── dashboards/
│       │   └── dashboard.json              # Pre-built Grafana dashboard
│       └── provisioning/
│           ├── datasources/
│           │   └── datasource.yml          # Auto-provision Prometheus source
│           └── dashboards/
│               └── dashboard-provider.yml  # Auto-provision dashboard
├── tests/
│   └── test_app.py                         # Unit tests (pytest) — 17 tests
├── .flake8                                 # Linter configuration
├── Dockerfile                              # Multi-layer, non-root, healthcheck
├── docker-compose.yml                      # Production deploy
├── docker-compose.monitoring.yml           # Full monitoring stack
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
- ✅ Prometheus metrics (official library)
- ✅ Grafana dashboards with alerting rules
- ✅ Pinned dependency versions
- ✅ Automated CI/CD pipeline
- ✅ Linting enforced on every push

---

## 🌐 Live Demo

🔗 **[https://devops-lab-i12g.onrender.com](https://devops-lab-i12g.onrender.com)**

Try it:
```bash
curl https://devops-lab-i12g.onrender.com/health
curl https://devops-lab-i12g.onrender.com/metrics
curl https://devops-lab-i12g.onrender.com/metrics/prometheus
```

---

## 🗺️ Roadmap

| Stage | Focus                              | Status     |
| ----- | ---------------------------------- | ---------- |
| **1** | App + Docker + Cloud Deploy        | ✅ Complete |
| **2** | CI/CD Pipeline (GitHub Actions)    | ✅ Complete |
| **3** | Monitoring & Alerting (Prometheus) | ✅ Complete |
| **4** | Infrastructure as Code (Terraform) | ⬜ Next     |
| **5** | Kubernetes (k3s, Helm)             | ⬜          |
| **6** | GitOps (ArgoCD)                    | ⬜          |
