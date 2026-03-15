# ============================================================================
# Terraform Provider Configuration
# ============================================================================
# WHAT:  Tells Terraform which cloud provider to use (Render).
# WHY:   Just like pip needs to know which packages to install,
#        Terraform needs to know which provider plugin to download.
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.6"
    }
  }
}

# ── Render Provider ────────────────────────────────────────────────────────────
# Reads api_key and owner_id from variables (set in terraform.tfvars)
provider "render" {
  api_key  = var.render_api_key
  owner_id = var.render_owner_id
}
