#!/bin/bash

# Bella Sicilia - Initial AWS Setup Script
# This script sets up the S3 bucket and uploads the initial site

set -e

BUCKET_NAME="bellasicilia-website"
REGION="us-east-1"

echo "🏗️  Setting up Bella Sicilia on AWS..."
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity --output text &> /dev/null; then
    echo "❌ Error: AWS CLI not configured"
    echo "Run: aws configure"
    exit 1
fi

echo "✅ AWS CLI configured"
echo ""

# Create S3 bucket
echo "📦 Creating S3 bucket: $BUCKET_NAME..."
if aws s3 mb s3://$BUCKET_NAME --region $REGION 2>/dev/null; then
    echo "✅ Bucket created"
else
    echo "⚠️  Bucket already exists (or error occurred)"
fi

# Enable static website hosting
echo "🌐 Enabling static website hosting..."
aws s3 website s3://$BUCKET_NAME \
    --index-document index.html \
    --error-document index.html

echo "✅ Static hosting enabled"

# Apply bucket policy
echo "🔓 Making bucket public..."
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://bucket-policy.json

echo "✅ Bucket policy applied"

# Initial upload
echo "📤 Uploading website files..."
aws s3 sync . s3://$BUCKET_NAME \
    --exclude ".git/*" \
    --exclude "*.sh" \
    --exclude "*.md" \
    --exclude "*.json" \
    --exclude ".DS_Store" \
    --exclude "pizza-hero.png"

echo "✅ Files uploaded"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ S3 Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 S3 Website URL:"
echo "   http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔒 Create SSL Certificate (ACM in us-east-1):"
echo "   aws acm request-certificate \\"
echo "     --domain-name bellasiciliawhitehall.com \\"
echo "     --validation-method DNS \\"
echo "     --region us-east-1"
echo ""
echo "2. ✅ Validate certificate via DNS (add CNAME records)"
echo ""
echo "3. ⚡ Create CloudFront Distribution:"
echo "   - Origin: $BUCKET_NAME.s3.amazonaws.com"
echo "   - Alternate domain: bellasiciliawhitehall.com"
echo "   - SSL: Use ACM certificate"
echo "   - Default root object: index.html"
echo ""
echo "4. 🌐 Update DNS:"
echo "   Add A record (Alias) or CNAME to CloudFront distribution"
echo ""
echo "5. 🚀 Future deployments:"
echo "   ./deploy-aws.sh YOUR_CLOUDFRONT_ID"
echo ""
