"""Unit tests for the DevOps Monitoring API."""

import sys
import os
import pytest

# Ensure the app module is importable
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from app import app  # noqa: E402


@pytest.fixture
def client():
    """Create a Flask test client."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


# ── Index ──────────────────────────────────────────────────────────────────────
def test_index_returns_200(client):
    resp = client.get("/")
    assert resp.status_code == 200


def test_index_lists_endpoints(client):
    data = client.get("/").get_json()
    assert "endpoints" in data
    assert "/health" in data["endpoints"]
    assert "/metrics" in data["endpoints"]


# ── Health ─────────────────────────────────────────────────────────────────────
def test_health_returns_200(client):
    resp = client.get("/health")
    assert resp.status_code == 200


def test_health_contains_required_fields(client):
    data = client.get("/health").get_json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert "uptime_seconds" in data
    assert "requests_served" in data
    assert "timestamp" in data


# ── Metrics ────────────────────────────────────────────────────────────────────
def test_metrics_returns_200(client):
    resp = client.get("/metrics")
    assert resp.status_code == 200


def test_metrics_contains_system_data(client):
    data = client.get("/metrics").get_json()
    assert "cpu_percent" in data
    assert "cpu_count" in data
    assert "memory" in data
    assert "percent" in data["memory"]
    assert "disk" in data
    assert "network" in data


# ── Prometheus Metrics ─────────────────────────────────────────────────────────
def test_prometheus_returns_200(client):
    resp = client.get("/metrics/prometheus")
    assert resp.status_code == 200


def test_prometheus_content_type(client):
    resp = client.get("/metrics/prometheus")
    assert "text/plain" in resp.content_type


def test_prometheus_contains_metrics(client):
    text = client.get("/metrics/prometheus").data.decode()
    assert "cpu_usage_percent" in text
    assert "memory_usage_bytes" in text
    assert "app_uptime_seconds" in text


# ── Prometheus Client (official library) ───────────────────────────────────────
def test_prom_endpoint_returns_200(client):
    resp = client.get("/metrics/prom")
    assert resp.status_code == 200


def test_prom_content_type(client):
    resp = client.get("/metrics/prom")
    assert "text/plain" in resp.content_type or "text/plain" in resp.content_type


def test_prom_contains_standard_metrics(client):
    text = client.get("/metrics/prom").data.decode()
    assert "cpu_usage_percent" in text
    assert "http_request_duration_seconds" in text


# ── Info ───────────────────────────────────────────────────────────────────────
def test_info_returns_200(client):
    resp = client.get("/info")
    assert resp.status_code == 200


def test_info_contains_required_fields(client):
    data = client.get("/info").get_json()
    assert "os" in data
    assert "hostname" in data
    assert "python_version" in data
    assert "architecture" in data


# ── Processes ──────────────────────────────────────────────────────────────────
def test_processes_returns_200(client):
    resp = client.get("/processes")
    assert resp.status_code == 200


def test_processes_returns_list(client):
    data = client.get("/processes").get_json()
    assert "top_processes" in data
    assert isinstance(data["top_processes"], list)


# ── Error Handling ─────────────────────────────────────────────────────────────
def test_404_returns_json(client):
    resp = client.get("/nonexistent")
    assert resp.status_code == 404
    data = resp.get_json()
    assert "error" in data
