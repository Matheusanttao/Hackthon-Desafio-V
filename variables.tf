variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "credentials_file_path" {
  description = "Path to the GCP credentials file"
  type        = string
}
