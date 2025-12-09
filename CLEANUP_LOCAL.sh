#!/bin/bash

echo "📦 Adding 4 Categories to Sister Mau..."
echo ""

DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'db|database' | head -1)
WEB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'app$|web' | head -1)

# Add categories
echo "➕ Adding categories..."
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry << 'EOSQL'
-- Clear existing categories
DELETE FROM categories;

-- Add 4 new categories
INSERT INTO categories (id, category, status) VALUES
(1, 'TVs', 1),
(2, 'Surround Sounds', 1),
(3, 'Furniture', 1),
(4, 'Cars', 1);

-- Show what was added
SELECT * FROM categories;
EOSQL

echo ""
echo "✅ Categories added!"
echo ""
echo "📊 Current categories:"
docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry -e "SELECT id, category, status FROM categories;" 2>/dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SUCCESS! 4 Categories Added"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Categories added:"
echo "   1. TVs"
echo "   2. Surround Sounds"
echo "   3. Furniture"
echo "   4. Cars"
echo ""
echo "🌐 Refresh your browser: http://localhost:3000"
echo "   Press Ctrl+Shift+R to see the categories!"
echo ""
echo "📝 Next: Add products via Admin Panel"
echo "   http://localhost:3000/Admin/"
echo ""