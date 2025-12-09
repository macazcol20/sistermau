#!/bin/bash

echo "👤 Creating Admin Account..."
echo ""

DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'db|database' | head -1)

# Check admin table structure first
echo "📊 Checking admin table structure..."
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry -e "DESCRIBE admin;" 2>/dev/null

echo ""
echo "➕ Creating admin account..."

# Insert admin account
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry << 'EOSQL' 2>/dev/null
DELETE FROM admin;
INSERT INTO admin (name, email, phone, password) VALUES
('Admin User', 'admin@sistermau.com', '0700000000', MD5('admin123'));

SELECT 'Admin account created!' as Status;
SELECT id, name, email, phone FROM admin;
EOSQL

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ADMIN ACCOUNT CREATED!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔑 Login Credentials:"
echo ""
echo "   📧 Email:    admin@sistermau.com"
echo "   🔒 Password: admin123"
echo ""
echo "🌐 Login URL: http://localhost:3000/Admin/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""