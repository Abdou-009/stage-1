# ============================================================================
# Input Variables
# ============================================================================
# WHAT:  Configurable settings for the Terraform configuration.
# WHY:   Variables let you reuse the same code with different values.
#        Think of them like function parameters — same code, different inputs.
# ============================================================================

# ── Authentication ─────────────────────────────────────────────────────────────

variable "render_api_key" {
  description = "Render API key (from Dashboard → Account Settings → API Keys)"
  type        = string
  sensitive   = true   # ← Terraform won't print this in logs
}

variable "render_owner_id" {
  description = "Render owner ID (starts with usr- or tea-)"
  type        = string
}

# ── Service Configuration ──────────────────────────────────────────────────────

variable "service_name" {
  description = "Name of the web service on Render"
  type        = string
  default     = "devops-lab"
}

variable "service_region" {
  description = "Render region to deploy in"
  type        = string
  default     = "oregon"
}

variable "service_plan" {
  description = "Render plan (free, starter, standard, pro)"
  type        = string
  default     = "free"
}

variable "repo_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/Abdou-009/DevOps_Project"
}

variable "branch" {
  description = "Git branch to deploy from"
  type        = string
  default     = "main"
}

variable "app_version" {
  description = "Application version to set as environment variable"
  type        = string
  default     = "1.2.0"
}

variable "environment_id" {
  description = "Render project environment ID"
  type        = string
}
