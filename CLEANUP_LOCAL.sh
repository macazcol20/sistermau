#!/bin/bash

echo "🔧 Fixing SQL Syntax Error"
echo ""

SQL_FILE=~/maureen-ecommerce/database/grocerry.sql

# Remove the bad additions
echo "Restoring original SQL from backup..."
if [ -f "${SQL_FILE}.backup" ]; then
    cp "${SQL_FILE}.backup" "$SQL_FILE"
    echo "✅ Original restored"
else
    echo "❌ No backup found!"
    exit 1
fi

echo ""
echo "Adding correct SQL syntax..."
echo ""

# Add correct SQL (MySQL compatible)
cat >> "$SQL_FILE" << 'SQLEOF'

-- ============================================
-- SISTER MAU CUSTOMIZATIONS
-- ============================================

-- Add image column to categories (MySQL compatible way)
SET @col_exists = (SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'grocerry' 
    AND TABLE_NAME = 'categories' 
    AND COLUMN_NAME = 'image');

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE categories ADD COLUMN image VARCHAR(255) AFTER category', 
    'SELECT "Column already exists" AS info');

PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Clear and populate categories
DELETE FROM categories;
INSERT INTO categories (id, category, image, status) VALUES
(1, 'TVs', 'samsung-tv.jpg', 1),
(2, 'Surround Sounds', 'soundbar.jpg', 1),
(3, 'Furniture', 'furniture.jpg', 1),
(4, 'Cars', 'car.jpg', 1),
(5, 'Laptops', 'laptop.jpg', 1);

-- Create admin account
DELETE FROM admin;
INSERT INTO admin (username, password) VALUES ('admin', MD5('admin123'));

-- ============================================
-- END CUSTOMIZATIONS
-- ============================================
SQLEOF

echo "✅ SQL file fixed!"
echo ""
echo "Now rebuild:"
echo "  docker-compose down"
echo "  docker-compose up -d --build"
echo ""