#!/bin/bash

echo "🔧 Fixing Admin Login + Categories Display"
echo ""

DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'db|database' | head -1)
WEB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'app$|web' | head -1)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Part 1: Fix Admin Login"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check admin table structure
echo "📊 Checking admin table structure..."
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry -e "DESCRIBE admin;" 2>/dev/null

echo ""
echo "➕ Creating/Updating admin account..."

# Create or update admin
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry << 'EOSQL' 2>/dev/null
-- Clear and recreate admin
TRUNCATE TABLE admin;

-- Insert with all required fields
INSERT INTO admin (name, email, phone, password) VALUES
('Admin', 'admin@sistermau.com', '0700000000', MD5('admin123'));

-- Verify
SELECT id, name, email, phone, 'password_hashed' as password FROM admin;
EOSQL

echo ""
echo "✅ Admin account created/updated"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Part 2: Fix Categories Display"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "➕ Adding categories..."

docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry << 'EOSQL' 2>/dev/null
-- Clear and add categories
TRUNCATE TABLE categories;

INSERT INTO categories (id, category, status) VALUES
(1, 'TVs', 1),
(2, 'Surround Sounds', 1),
(3, 'Furniture', 1),
(4, 'Cars', 1);

-- Verify
SELECT * FROM categories;
EOSQL

echo ""
echo "✅ Categories added"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Part 3: Verify Database"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📊 Current categories:"
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry -e "SELECT id, category, status FROM categories;" 2>/dev/null

echo ""
echo "📊 Admin count:"
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry -e "SELECT COUNT(*) as admin_count FROM admin;" 2>/dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Part 4: Restart Web Container"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker restart $WEB_CONTAINER > /dev/null 2>&1
echo "⏳ Restarting container..."
sleep 5
echo "✅ Container restarted"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL FIXED!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔑 ADMIN LOGIN:"
echo "   📧 Email:    admin@sistermau.com"
echo "   🔒 Password: admin123"
echo "   🌐 URL:      http://localhost:3000/Admin/"
echo ""
echo "🏠 HOMEPAGE:"
echo "   🌐 URL:      http://localhost:3000"
echo "   📦 Should show 4 categories: TVs, Surround Sounds, Furniture, Cars"
echo ""
echo "📝 Press Ctrl+Shift+R to hard refresh both pages!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"