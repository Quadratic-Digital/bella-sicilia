# Bella Sicilia Pizza & Subs

Authentic Sicilian pizza and Italian food website for Bella Sicilia in Whitehall, MD.

**Repository**: https://github.com/Quadratic-Digital/bella-sicilia

## 🚀 Quick Deploy to AWS

### First Time Setup

```bash
# 1. Run the setup script
./setup-aws.sh

# 2. Create SSL certificate (follow output instructions)

# 3. Create CloudFront distribution (see AWS-SETUP.md)

# 4. Update DNS to point to CloudFront
```

### Future Updates

```bash
# Deploy changes
./deploy-aws.sh YOUR_CLOUDFRONT_DISTRIBUTION_ID
```

## 🌐 Live URL

**Production**: https://bellasicilia.quadratic-digital.com

## 📁 Project Structure

```
bella-sicilia/
├── index.html              # Homepage
├── menu.html               # Full menu page
├── about.html              # Our Story page
├── contact.html            # Contact & Order page
├── styles.css              # Main stylesheet
├── menu-styles.css         # Menu-specific styles
├── about-styles.css        # About-specific styles
├── contact-styles.css      # Contact-specific styles
├── script.js               # JavaScript functionality
├── bella-logo.png          # Restaurant logo
└── pizza-hero.png          # Hero image (unused)
```

## 🛠️ Tech Stack

- **HTML5** - Semantic markup
- **CSS3** - Custom properties, Grid, Flexbox
- **Vanilla JavaScript** - Smooth interactions
- **Google Fonts** - Cormorant Garamond & Josefin Sans
- **AWS S3 + CloudFront** - Hosting & CDN

## 🎨 Design

- **Color Scheme**: Red (#C41E3A), Green (#2E5339), Gold (#DAA520), Cream (#FDF5E6)
- **Typography**: Serif headers (Cormorant Garamond), Sans body (Josefin Sans)
- **Responsive**: Mobile-first design with breakpoints at 768px, 1024px

## 📝 Key Features

- ✅ Fully responsive design
- ✅ Fixed navigation with mobile menu
- ✅ Smooth scroll animations
- ✅ Menu organized by category
- ✅ Custom branding throughout
- ✅ SEO-friendly markup
- ✅ Fast loading (optimized images)

## 🔧 Development

### Local Testing

```bash
# Open in browser
open index.html

# Or use a local server
python3 -m http.server 8000
# Visit http://localhost:8000
```

### Making Changes

1. Edit files locally
2. Test in browser
3. Deploy to AWS:
   ```bash
   ./deploy-aws.sh YOUR_CLOUDFRONT_ID
   ```

## 📚 Documentation

- **[AWS-SETUP.md](AWS-SETUP.md)** - Complete AWS deployment guide
- **[deploy-aws.sh](deploy-aws.sh)** - Automated deployment script
- **[setup-aws.sh](setup-aws.sh)** - Initial AWS setup script

## 💰 AWS Costs

Estimated monthly costs for typical traffic:
- **S3**: ~$0.001/month (storage)
- **CloudFront**: First 1TB free
- **Route 53**: $0.50/month
- **ACM**: Free

**Total**: ~$1-2/month

## 📞 Contact

Bella Sicilia Pizza & Subs
Whitehall, MD
Hours: Sun-Thu 11am-9pm, Fri-Sat 11am-10pm

---

Built with ❤️ for Bella Sicilia
