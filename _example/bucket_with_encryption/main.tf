provider "google" {
  project = "soy-smile-435017-c5"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

module "kms_key" {
  source          = "git::https://github.com/SyncArcs/terraform-google-kms.git?ref=v1.0.0"
  name            = "SyncArcs"
  environment     = "test"
  location        = "us-central1"
  prevent_destroy = true
  keys            = ["test"]
  role            = ["roles/owner"]
}

module "bucket" {
  source      = "./../../"
  name        = "bucket-encryption"
  environment = "test"
  location    = "us-central1"
  encryption = {
    kms_key = module.kms_key.key_id
  }

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age            = 365
      with_state     = "ANY"
      matches_prefix = "test12"
    }
  }]

  iam_members = [
    {
      role   = "roles/storage.admin"
      member = "group:test-gcp-ops@test.blueprints.joonix.net"
    }
  ]
  autoclass = true
}
