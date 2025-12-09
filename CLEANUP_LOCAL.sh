#!/bin/bash

echo "🔧 Fixing SQL File - Add Database Selection"
echo ""

SQL_FILE=~/maureen-ecommerce/database/grocerry.sql

if [ ! -f "$SQL_FILE" ]; then
    echo "❌ SQL file not found!"
    exit 1
fi

# Backup
cp "$SQL_FILE" "${SQL_FILE}.nodbselect_backup"
echo "✅ Backup: ${SQL_FILE}.nodbselect_backup"
echo ""

# Check if already has CREATE DATABASE and USE
if grep -q "CREATE DATABASE.*grocerry" "$SQL_FILE" && grep -q "USE.*grocerry" "$SQL_FILE"; then
    echo "✅ SQL file already has database selection"
else
    echo "Adding database creation and selection..."
    
    # Create temp file with database setup at the beginning
    cat > /tmp/db_header.sql << 'SQLEOF'
-- Create database if not exists
CREATE DATABASE IF NOT EXISTS grocerry;
USE grocerry;

SQLEOF
    
    # Combine header + original file
    cat /tmp/db_header.sql "$SQL_FILE" > /tmp/grocerry_fixed.sql
    
    # Replace original
    mv /tmp/grocerry_fixed.sql "$SQL_FILE"
    rm /tmp/db_header.sql
    
    echo "✅ Added: CREATE DATABASE IF NOT EXISTS grocerry;"
    echo "✅ Added: USE grocerry;"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Fixing Dockerfile in database directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# The Dockerfile should NOT be copied to init directory
# Let's check the database Dockerfile
DB_DOCKERFILE=~/maureen-ecommerce/database/Dockerfile

if [ -f "$DB_DOCKERFILE" ]; then
    echo "Current Dockerfile content:"
    cat "$DB_DOCKERFILE"
    echo ""
    
    # Fix: Only copy .sql files, not everything
    cat > "$DB_DOCKERFILE" << 'DOCKERFILE'
FROM mysql:latest
COPY *.sql /docker-entrypoint-initdb.d/
DOCKERFILE
    
    echo "✅ Fixed Dockerfile to only copy .sql files"
else
    echo "⚠️  Dockerfile not found, creating..."
    cat > "$DB_DOCKERFILE" << 'DOCKERFILE'
FROM mysql:latest
COPY *.sql /docker-entrypoint-initdb.d/
DOCKERFILE
    echo "✅ Created Dockerfile"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ FIXES COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Changes made:"
echo "  1. Added 'CREATE DATABASE IF NOT EXISTS grocerry;' to SQL"
echo "  2. Added 'USE grocerry;' to SQL"
echo "  3. Fixed Dockerfile to only copy *.sql files"
echo ""
echo "Now rebuild:"
echo "  docker-compose down"
echo "  docker-compose up -d --build"
echo "  sleep 20"
echo ""