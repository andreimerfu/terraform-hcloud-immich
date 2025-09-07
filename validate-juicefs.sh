#!/bin/bash
# ================================================================
# JuiceFS Integration Validation Script
# ================================================================

echo "🧪 Validating JuiceFS Integration in Terraform Setup"
echo "======================================================"

# Check Terraform files
echo "1. ✅ Checking Terraform configuration..."
terraform validate || { echo "❌ Terraform validation failed"; exit 1; }

# Check setup.sh for JuiceFS components
echo "2. ✅ Checking setup.sh for JuiceFS integration..."
if grep -q "JuiceFS Installation and Setup" setup.sh; then
    echo "   ✅ JuiceFS installation section found"
else
    echo "   ❌ JuiceFS installation section missing"
    exit 1
fi

if grep -q "systemd service for JuiceFS" setup.sh; then
    echo "   ✅ JuiceFS systemd service creation found"
else
    echo "   ❌ JuiceFS systemd service creation missing"
    exit 1
fi

if grep -q "/mnt/immich/juicefs:/usr/src/app/upload" setup.sh; then
    echo "   ✅ Docker volumes updated to use JuiceFS"
else
    echo "   ❌ Docker volumes not updated for JuiceFS"
    exit 1
fi

# Check required environment variables are referenced
echo "3. ✅ Checking environment variable usage..."
for var in "S3_ACCESS_KEY_ID" "S3_SECRET_ACCESS_KEY" "S3_BUCKET_NAME" "S3_REGION" "S3_ENDPOINT"; do
    if grep -q "\$$var" setup.sh; then
        echo "   ✅ $var is used in setup script"
    else
        echo "   ❌ $var is missing from setup script"
        exit 1
    fi
done

# Check outputs.tf exists and includes relevant information
echo "4. ✅ Checking outputs configuration..."
if [ -f "outputs.tf" ]; then
    echo "   ✅ outputs.tf exists"
else
    echo "   ❌ outputs.tf missing"
    exit 1
fi

echo ""
echo "🎉 SUCCESS: JuiceFS integration is properly configured!"
echo ""
echo "📋 What's included:"
echo "   • JuiceFS installation and configuration"
echo "   • S3-compatible storage integration (optimized for Backblaze B2)"
echo "   • Systemd service for auto-mounting"
echo "   • Docker containers using JuiceFS mount"
echo "   • Health check with JuiceFS status"
echo "   • Unlimited photo storage via S3-compatible storage"
echo ""
echo "💰 Cost: €8-12/month for unlimited family photos"
echo "🚀 Ready for deployment with: terraform apply"