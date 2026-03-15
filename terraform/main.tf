# ============================================================================
# Main Infrastructure Definition
# ============================================================================
# WHAT:  Defines the Render web service — your app's cloud infrastructure.
# WHY:   This file IS your infrastructure. Instead of clicking through a
#        dashboard, you describe what you want and Terraform creates it.
# ============================================================================

resource "render_web_service" "devops_api" {
  name           = var.service_name
  plan           = var.service_plan
  region         = var.service_region
  environment_id = var.environment_id

  # ── Health Check ───────────────────────────────────────────────────────────
  # Render pings this path to check if your app is alive
  health_check_path = "/health"

  # ── Docker Runtime ─────────────────────────────────────────────────────────
  # Build from GitHub repo using the Dockerfile
  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.branch
      auto_deploy     = true               # Deploy on every push
      dockerfile_path = "./Dockerfile"
      context         = "."                 # Docker build context
    }
  }

  # ── Environment Variables ──────────────────────────────────────────────────
  env_vars = {
    "APP_VERSION" = { value = var.app_version }
  }

  # ── Notification Override (keep defaults) ──────────────────────────────────
  notification_override = {
    notifications_to_send         = "default"
    preview_notifications_enabled = "default"
  }

  # ── Lifecycle ──────────────────────────────────────────────────────────────
  # The Render API sends maintenance_mode in updates even when we don't set it,
  # which fails on the free tier. We ignore fields that the free tier can't manage.
  lifecycle {
    ignore_changes = [
      slug,
    ]
  }
}
