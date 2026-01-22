# SSL Certificate Setup for bellasiciliawhitehall.com

## Option 1: Add ACM Permissions to zion-deploy

Add this policy to the `zion-deploy` IAM user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ACMCertificateManagement",
      "Effect": "Allow",
      "Action": [
        "acm:RequestCertificate",
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:AddTagsToCertificate"
      ],
      "Resource": "*"
    }
  ]
}
```

Then run:
```bash
aws acm request-certificate \
  --domain-name bellasiciliawhitehall.com \
  --subject-alternative-names www.bellasiciliawhitehall.com \
  --validation-method DNS \
  --region us-east-1
```

---

## Option 2: Manual Setup via AWS Console (Recommended)

### Step 1: Request Certificate

1. Go to **AWS Certificate Manager** (ACM) in **us-east-1** region
2. Click **Request a certificate**
3. Choose **Request a public certificate**
4. Enter domain names:
   - `bellasiciliawhitehall.com`
   - `www.bellasiciliawhitehall.com`
5. Choose **DNS validation**
6. Click **Request**

### Step 2: Validate Certificate

1. Click on the certificate
2. Click **Create records in Route 53** (if using Route 53)
   - OR manually add the CNAME records to your DNS provider
3. Wait 5-30 minutes for validation

### Step 3: Note the Certificate ARN

Copy the Certificate ARN - you'll need it for CloudFront setup.

Example: `arn:aws:acm:us-east-1:740127659002:certificate/12345678-1234-1234-1234-123456789012`

---

## DNS Records Required

After certificate is issued, add these CNAME validation records to your DNS:

**You'll get these from ACM console:**
- Name: `_abc123.bellasiciliawhitehall.com`
- Type: `CNAME`
- Value: `_xyz456.acm-validations.aws.`

*(Exact values will be shown in ACM console)*

---

## Next: CloudFront Setup

Once certificate is **ISSUED** (not Pending Validation), proceed to create CloudFront distribution.
