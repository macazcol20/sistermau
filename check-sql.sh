#!/bin/bash

echo "🔍 Checking if Database Changes are in SQL File"
echo ""

SQL_FILE=$(find ~/ -name "grocerry.sql" -path "*/database/*" 2>/dev/null | head -1)

if [ -z "$SQL_FILE" ]; then
    echo "❌ Cannot find SQL file!"
    exit 1
fi

echo "📁 SQL File: $SQL_FILE"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Checking for Categories with Images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if grep -q "samsung-tv.jpg\|soundbar.jpg\|laptop.jpg" "$SQL_FILE"; then
    echo "✅ Categories with images found in SQL"
    echo ""
    echo "Sample lines:"
    grep -A2 "INSERT INTO.*categories" "$SQL_FILE" | head -10
else
    echo "❌ Categories NOT in SQL file!"
    echo "   Need to export database again"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Checking for Admin Account"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if grep -q "INSERT INTO.*admin\|INSERT INTO \`admin\`" "$SQL_FILE"; then
    echo "✅ Admin INSERT found in SQL"
    echo ""
    echo "Admin data:"
    grep -A2 "INSERT INTO.*admin" "$SQL_FILE" | head -5
else
    echo "❌ Admin account NOT in SQL file!"
    echo "   Need to export database again"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Checking for Image Column Definition"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if grep -B5 -A5 "CREATE TABLE.*categories" "$SQL_FILE" | grep -q "image.*varchar"; then
    echo "✅ Image column in categories table structure"
else
    echo "❌ Image column NOT in table structure!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "VERDICT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

CATEGORIES_OK=$(grep -q "samsung-tv.jpg" "$SQL_FILE" && echo "1" || echo "0")
ADMIN_OK=$(grep -q "INSERT INTO.*admin" "$SQL_FILE" && echo "1" || echo "0")
COLUMN_OK=$(grep -B5 -A5 "CREATE TABLE.*categories" "$SQL_FILE" | grep -q "image.*varchar" && echo "1" || echo "0")

if [ "$CATEGORIES_OK" = "1" ] && [ "$ADMIN_OK" = "1" ] && [ "$COLUMN_OK" = "1" ]; then
    echo "✅ ✅ ✅  SQL FILE IS COMPLETE!"
    echo ""
    echo "Your database is fully configured in:"
    echo "  $SQL_FILE"
    echo ""
    echo "🚀 Ready for Kubernetes deployment!"
    echo "   - Build Docker image with this SQL file"
    echo "   - Deploy to K8s cluster"
    echo "   - Categories and admin will be automatic"
    echo ""
else
    echo "⚠️  SQL FILE IS INCOMPLETE"
    echo ""
    echo "Status:"
    echo "  Categories: $([ "$CATEGORIES_OK" = "1" ] && echo "✅" || echo "❌")"
    echo "  Admin: $([ "$ADMIN_OK" = "1" ] && echo "✅" || echo "❌")"
    echo "  Image Column: $([ "$COLUMN_OK" = "1" ] && echo "✅" || echo "❌")"
    echo ""
    echo "Run ./EXPORT_DATABASE.sh to fix this"
fi

echo ""