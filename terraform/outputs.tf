# ============================================================================
# Outputs
# ============================================================================
# WHAT:  Values that Terraform prints after "terraform apply".
# WHY:   So you can quickly see the URL, service ID, etc. without
#        logging into the Render dashboard.
# ============================================================================

output "service_url" {
  description = "Live URL of the deployed service"
  value       = render_web_service.devops_api.url
}

output "service_id" {
  description = "Render service ID"
  value       = render_web_service.devops_api.id
}

output "service_slug" {
  description = "Render service slug"
  value       = render_web_service.devops_api.slug
}
