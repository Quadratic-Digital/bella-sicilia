#!/bin/bash

# Bella Sicilia - AWS S3 Deployment Script
# Domain: bellasicilia.quadratic-digital.com
# Usage: ./deploy-aws.sh [cloudfront-distribution-id]

set -e

# Default values
BUCKET_NAME="bellasicilia-website"
CLOUDFRONT_ID=$1

echo "🚀 Deploying Bella Sicilia to AWS..."
echo "📦 Bucket: $BUCKET_NAME"

# Sync files to S3
echo "📤 Uploading files to S3..."
aws s3 sync . s3://$BUCKET_NAME \
    --exclude ".git/*" \
    --exclude "*.sh" \
    --exclude ".DS_Store" \
    --exclude "README.md" \
    --cache-control "public, max-age=31536000" \
    --exclude "*.html" \
    --exclude "pizza-hero.png"

# Upload HTML files with shorter cache (for updates)
echo "📄 Uploading HTML files..."
aws s3 sync . s3://$BUCKET_NAME \
    --exclude "*" \
    --include "*.html" \
    --cache-control "public, max-age=3600" \
    --content-type "text/html"

# Set correct content types for CSS and JS
echo "🎨 Setting content types..."
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --exclude "*" \
    --include "*.css" \
    --content-type "text/css" \
    --metadata-directive REPLACE

aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --exclude "*" \
    --include "*.js" \
    --content-type "application/javascript" \
    --metadata-directive REPLACE

# Invalidate CloudFront cache if distribution ID provided
if [ ! -z "$CLOUDFRONT_ID" ]; then
    echo "🔄 Invalidating CloudFront cache..."
    aws cloudfront create-invalidation \
        --distribution-id $CLOUDFRONT_ID \
        --paths "/*"
    echo "✅ CloudFront invalidation created"
fi

echo ""
echo "✅ Deployment complete!"
echo "🌐 S3 URL: https://$BUCKET_NAME.s3.amazonaws.com/index.html"
echo "🌐 Live Site: https://bellasicilia.quadratic-digital.com"
if [ ! -z "$CLOUDFRONT_ID" ]; then
    echo "⚡ CloudFront cache invalidated - changes will propagate in 1-2 minutes"
else
    echo "⚠️  Tip: Add CloudFront distribution ID for cache invalidation"
    echo "   Usage: ./deploy-aws.sh YOUR_CLOUDFRONT_ID"
fi
