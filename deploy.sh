#!/usr/bin/env bash
# ==============================================================================
# Deploy Qwen2.5-1.5B to Google Cloud Run (Free Tier Optimized)
# ==============================================================================

set -e

# Configuration (Customize if needed)
SERVICE_NAME="qwen-1-5b"
REGION="us-central1"
IMAGE_TAG="gcr.io/$(gcloud config get-value project)/${SERVICE_NAME}:latest"

echo "============================================================"
echo " Project ID: $(gcloud config get-value project)"
echo " Service:    ${SERVICE_NAME}"
echo " Region:     ${REGION}"
echo " Image:      ${IMAGE_TAG}"
echo "============================================================"

# 1. Enable required Google Cloud services
echo "[1/3] Enabling Cloud Build and Cloud Run APIs..."
gcloud services enable run.googleapis.com cloudbuild.googleapis.com

# 2. Build image via Google Cloud Build (runs in the cloud, no local Docker needed)
echo "[2/3] Building container image in Google Cloud Build..."
gcloud builds submit --tag "${IMAGE_TAG}" .

# 3. Deploy to Cloud Run with Free Tier parameters
echo "[3/3] Deploying to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE_TAG}" \
  --platform managed \
  --region "${REGION}" \
  --allow-unauthenticated \
  --cpu 2 \
  --memory 2Gi \
  --min-instances 0 \
  --max-instances 1 \
  --concurrency 4 \
  --timeout 300 \
  --no-cpu-throttling=false

echo "============================================================"
echo "Deployment Complete!"
SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}" --format="value(status.url)")
echo "Service URL: ${SERVICE_URL}"
echo "Test endpoint: ${SERVICE_URL}/v1/chat/completions"
echo "============================================================"
