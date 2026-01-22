# AWS Deployment Guide for Bella Sicilia
## Custom Domain: bellasicilia.quadratic-digital.com

### Prerequisites
- AWS CLI configured with appropriate credentials
- Access to Route 53 (or DNS provider for quadratic-digital.com)

---

## Step 1: Create S3 Bucket

```bash
# Create bucket (name can be anything, doesn't need to match domain)
aws s3 mb s3://bellasicilia-website --region us-east-1

# Enable static website hosting
aws s3 website s3://bellasicilia-website \
    --index-document index.html \
    --error-document index.html
```

### Configure Bucket Policy
Create a file `bucket-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bellasicilia-website/*"
    }
  ]
}
```

Apply policy:
```bash
aws s3api put-bucket-policy \
    --bucket bellasicilia-website \
    --policy file://bucket-policy.json
```

---

## Step 2: Request SSL Certificate (ACM)

**IMPORTANT:** Certificate MUST be in us-east-1 for CloudFront!

```bash
# Request certificate
aws acm request-certificate \
    --domain-name bellasicilia.quadratic-digital.com \
    --validation-method DNS \
    --region us-east-1

# Note the CertificateArn from output
```

### Validate Certificate
1. Go to ACM Console (us-east-1)
2. Click on the certificate
3. Add the CNAME records to your DNS (Route 53 or other)
4. Wait for validation (usually 5-30 minutes)

---

## Step 3: Create CloudFront Distribution

Save this as `cloudfront-config.json`:

```json
{
  "CallerReference": "bellasicilia-2026-01-22",
  "Comment": "Bella Sicilia Website",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-bellasicilia-website",
        "DomainName": "bellasicilia-website.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultRootObject": "index.html",
  "Aliases": {
    "Quantity": 1,
    "Items": ["bellasicilia.quadratic-digital.com"]
  },
  "ViewerCertificate": {
    "ACMCertificateArn": "YOUR_CERTIFICATE_ARN_HERE",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-bellasicilia-website",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "Compress": true,
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    }
  }
}
```

Or create via Console (easier):
1. Go to CloudFront Console
2. Create Distribution
3. **Origin Domain**: Select your S3 bucket
4. **Alternate Domain Names**: `bellasicilia.quadratic-digital.com`
5. **SSL Certificate**: Select your ACM certificate
6. **Viewer Protocol Policy**: Redirect HTTP to HTTPS
7. **Default Root Object**: `index.html`
8. Create

---

## Step 4: Update DNS (Route 53)

### If using Route 53:

```bash
# Get CloudFront domain name (e.g., d1234abcd.cloudfront.net)
aws cloudfront list-distributions \
    --query "DistributionList.Items[?Comment=='Bella Sicilia Website'].DomainName" \
    --output text

# Get Hosted Zone ID for quadratic-digital.com
aws route53 list-hosted-zones \
    --query "HostedZones[?Name=='quadratic-digital.com.'].Id" \
    --output text
```

Create `route53-record.json`:

```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "bellasicilia.quadratic-digital.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "d1234abcd.cloudfront.net",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
```

Apply:
```bash
aws route53 change-resource-record-sets \
    --hosted-zone-id YOUR_ZONE_ID \
    --change-batch file://route53-record.json
```

### If using external DNS:
Add a CNAME record:
- **Name**: `bellasicilia`
- **Type**: `CNAME`
- **Value**: `d1234abcd.cloudfront.net` (your CloudFront domain)

---

## Step 5: Deploy Website

Use the deployment script:

```bash
chmod +x deploy-aws.sh

# Deploy (replace with your actual IDs)
./deploy-aws.sh bellasicilia-website YOUR_CLOUDFRONT_DISTRIBUTION_ID
```

---

## Quick Setup Script (All-in-One)

```bash
# Set variables
BUCKET_NAME="bellasicilia-website"
DOMAIN="bellasicilia.quadratic-digital.com"
REGION="us-east-1"

# 1. Create bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# 2. Enable static hosting
aws s3 website s3://$BUCKET_NAME \
    --index-document index.html

# 3. Upload files
aws s3 sync . s3://$BUCKET_NAME \
    --exclude ".git/*" \
    --exclude "*.sh" \
    --exclude "*.md"

# 4. Make bucket public
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://bucket-policy.json

echo "✅ S3 bucket created and website uploaded!"
echo "⚠️  Next steps:"
echo "1. Create ACM certificate in us-east-1"
echo "2. Create CloudFront distribution"
echo "3. Update DNS to point to CloudFront"
```

---

## Maintenance

### Update Website:
```bash
./deploy-aws.sh bellasicilia-website YOUR_CLOUDFRONT_ID
```

### Manual Upload:
```bash
aws s3 sync . s3://bellasicilia-website \
    --exclude ".git/*" \
    --exclude "*.sh" \
    --delete
```

### Clear CloudFront Cache:
```bash
aws cloudfront create-invalidation \
    --distribution-id YOUR_DISTRIBUTION_ID \
    --paths "/*"
```

---

## Estimated Costs

- **S3 Storage**: ~$0.023/GB/month (site is ~1.5MB = $0.001/month)
- **S3 Requests**: ~$0.004 per 10,000 requests
- **CloudFront**: First 1TB free, then $0.085/GB
- **Route 53**: $0.50/month per hosted zone
- **ACM Certificate**: FREE

**Total**: ~$1-5/month for typical traffic
