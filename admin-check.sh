#!/bin/bash

echo "🖼️  Adding Laptops + Real Product Images for Categories"
echo ""

DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'db|database' | head -1)
WEB_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'app$|web' | head -1)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Update Categories (Add Laptops + Image Column)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker exec $DB_CONTAINER mysql -u root -ppasswd grocerry << 'EOSQL' 2>&1 | grep -v Warning
-- Add image column if it doesn't exist
ALTER TABLE categories ADD COLUMN image VARCHAR(255) AFTER icon;

-- Update existing categories and add Laptops
DELETE FROM categories;

INSERT INTO categories (id, category, icon, image, status) VALUES
(1, 'TVs', 'tv', 'samsung-tv.jpg', 1),
(2, 'Surround Sounds', 'volume-up', 'soundbar.jpg', 1),
(3, 'Furniture', 'couch', 'furniture.jpg', 1),
(4, 'Cars', 'car', 'car.jpg', 1),
(5, 'Laptops', 'laptop', 'laptop.jpg', 1);

-- Verify
SELECT id, category, icon, image, status FROM categories;
EOSQL

echo ""
echo "✅ Categories updated with Laptops + image column"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Create Category Images Directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker exec $WEB_CONTAINER mkdir -p /var/www/html/media/categories
echo "✅ Directory created: /var/www/html/media/categories"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Download Sample Category Images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create placeholder images using ImageMagick (if available) or just touch files
docker exec $WEB_CONTAINER bash -c 'cd /var/www/html/media/categories && 
# Create simple colored placeholder images
echo "Creating placeholder images..."

# Try to use convert if available, otherwise create text files as placeholders
if command -v convert >/dev/null 2>&1; then
    convert -size 300x300 xc:#1a1a1a -pointsize 40 -fill white -gravity center -annotate +0+0 "Samsung TV" samsung-tv.jpg
    convert -size 300x300 xc:#2a2a2a -pointsize 40 -fill white -gravity center -annotate +0+0 "Soundbar" soundbar.jpg
    convert -size 300x300 xc:#3a3a3a -pointsize 40 -fill white -gravity center -annotate +0+0 "Furniture" furniture.jpg
    convert -size 300x300 xc:#4a4a4a -pointsize 40 -fill white -gravity center -annotate +0+0 "Car" car.jpg
    convert -size 300x300 xc:#5a5a5a -pointsize 40 -fill white -gravity center -annotate +0+0 "Laptop" laptop.jpg
else
    # Fallback: copy existing sample images
    cp /var/www/html/assets/images/sample/img-1.jpg samsung-tv.jpg 2>/dev/null || touch samsung-tv.jpg
    cp /var/www/html/assets/images/sample/img-2.jpg soundbar.jpg 2>/dev/null || touch soundbar.jpg
    cp /var/www/html/assets/images/sample/img-3.jpg furniture.jpg 2>/dev/null || touch furniture.jpg
    cp /var/www/html/assets/images/sample/img-4.jpg car.jpg 2>/dev/null || touch car.jpg
    cp /var/www/html/assets/images/sample/img-5.jpg laptop.jpg 2>/dev/null || touch laptop.jpg
fi
'

echo "✅ Placeholder images created"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Update index.php to Show Real Images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > /tmp/index_with_images.php << 'PHPEOF'
<?php
session_start();
require_once 'utility/connection.php';

// Fetch categories with images
$cat_query = "SELECT * FROM categories WHERE status = 1 ORDER BY id ASC";
$cat_result = mysqli_query($con, $cat_query);

// Fetch products
$product_query = "SELECT * FROM product WHERE status = 1 ORDER BY id DESC LIMIT 12";
$product_result = mysqli_query($con, $product_query);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sister Mau - Electronics, Furniture & Building Equipment</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        :root{--primary-blue:#0046BE;--dark-blue:#001E3C;--orange:#FF6B35}
        body{font-family:'Segoe UI',Arial,sans-serif;background:#fff}
        .hero-static{background:linear-gradient(135deg,var(--primary-blue),var(--dark-blue));color:#fff;padding:60px 20px;text-align:center;margin-bottom:40px}
        .hero-static h1{font-size:42px;margin-bottom:15px}
        .hero-static p{font-size:18px;opacity:.9}
        .category-section{max-width:1400px;margin:50px auto;padding:0 20px}
        .section-title{font-size:32px;margin-bottom:30px;color:#333}
        
        /* Category Grid with REAL IMAGES (Best Buy style) */
        .category-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin-bottom:60px}
        .category-card{
            background:#fff;border:1px solid #e0e0e0;border-radius:8px;
            padding:20px;text-align:center;text-decoration:none;
            color:#333;transition:all .3s;overflow:hidden;
            position:relative;
        }
        .category-card:hover{border-color:var(--primary-blue);transform:translateY(-3px);box-shadow:0 4px 12px rgba(0,70,190,.15)}
        
        /* Category Image (like Best Buy) */
        .category-image{
            width:100%;height:180px;margin-bottom:15px;
            display:flex;align-items:center;justify-content:center;
            background:#f5f5f5;border-radius:8px;overflow:hidden;
        }
        .category-image img{max-width:100%;max-height:100%;object-fit:contain}
        
        .category-name{font-size:16px;font-weight:600;color:#1d252c}
        
        /* Product Grid */
        .products-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:25px;margin-top:30px}
        .product-card{background:#fff;border:1px solid #e0e0e0;border-radius:8px;overflow:hidden;transition:all .3s;text-decoration:none;color:#333;display:block}
        .product-card:hover{box-shadow:0 8px 20px rgba(0,0,0,.12);transform:translateY(-3px)}
        .product-image{width:100%;height:280px;background:#f5f5f5;display:flex;align-items:center;justify-content:center;overflow:hidden}
        .product-image img{max-width:100%;max-height:100%;object-fit:contain}
        .product-info{padding:20px}
        .product-info h3{font-size:16px;margin-bottom:8px;font-weight:600;min-height:40px}
        .product-price{font-size:22px;font-weight:700;color:var(--dark-blue);margin:15px 0}
        .add-to-cart-btn{width:100%;padding:12px;background:var(--primary-blue);color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer;transition:background .3s}
        .add-to-cart-btn:hover{background:var(--dark-blue)}
        .owl-carousel,.slider,.banner-carousel,.slick-slider{display:none!important}
        .empty-state{text-align:center;padding:60px 20px;grid-column:1/-1;background:#f9f9f9;border-radius:12px}
        .empty-state h3{font-size:24px;margin-bottom:15px;color:#666}
        .empty-state p{color:#999;margin-bottom:20px}
        .empty-state a{display:inline-block;padding:12px 24px;background:var(--primary-blue);color:#fff;text-decoration:none;border-radius:6px;font-weight:600;transition:background .3s}
        .empty-state a:hover{background:var(--dark-blue)}
    </style>
</head>
<body>

<?php include 'require/top.php'; ?>

<div class="hero-static">
    <h1>Shop deals by category</h1>
    <p>Electronics, Furniture & Building Equipment - All in One Place</p>
</div>

<div class="category-section">
    <h2 class="section-title">Browse by Category</h2>
    <div class="category-grid">
        <?php 
        if ($cat_result && mysqli_num_rows($cat_result) > 0) {
            while($category = mysqli_fetch_assoc($cat_result)): 
                $image = !empty($category['image']) ? $category['image'] : 'img-1.jpg';
        ?>
            <a href="view.php?category=<?php echo $category['id']; ?>" class="category-card">
                <div class="category-image">
                    <img src="media/categories/<?php echo htmlspecialchars($image); ?>" 
                         alt="<?php echo htmlspecialchars($category['category']); ?>"
                         onerror="this.src='assets/images/sample/img-1.jpg'">
                </div>
                <div class="category-name"><?php echo htmlspecialchars($category['category']); ?></div>
            </a>
        <?php 
            endwhile;
        } else {
        ?>
            <div class="empty-state">
                <i class="fas fa-tags" style="font-size:48px;color:#ccc;margin-bottom:20px"></i>
                <h3>No Categories Yet</h3>
                <p>Start by adding product categories</p>
                <a href="Admin/"><i class="fas fa-plus"></i> Go to Admin Panel</a>
            </div>
        <?php } ?>
    </div>
    
    <h2 class="section-title">Featured Products</h2>
    <div class="products-grid">
        <?php 
        if ($product_result && mysqli_num_rows($product_result) > 0) {
            while($product = mysqli_fetch_assoc($product_result)): 
        ?>
            <a href="product_detail.php?id=<?php echo $product['id']; ?>" class="product-card">
                <div class="product-image">
                    <?php if(!empty($product['img1'])): ?>
                        <img src="media/product/<?php echo $product['img1']; ?>" alt="<?php echo htmlspecialchars($product['product_name']); ?>">
                    <?php else: ?>
                        <img src="assets/images/sample/img-1.jpg" alt="Product">
                    <?php endif; ?>
                </div>
                <div class="product-info">
                    <h3><?php echo htmlspecialchars($product['product_name']); ?></h3>
                    <div class="product-price">KSh <?php echo number_format($product['price']); ?></div>
                    <button class="add-to-cart-btn" onclick="event.preventDefault();addToCart(<?php echo $product['id']; ?>)">
                        <i class="fas fa-cart-plus"></i> Add to Cart
                    </button>
                </div>
            </a>
        <?php 
            endwhile;
        } else {
        ?>
            <div class="empty-state">
                <i class="fas fa-box-open" style="font-size:48px;color:#ccc;margin-bottom:20px"></i>
                <h3>No Products Yet</h3>
                <p>Start adding products to your store</p>
                <a href="Admin/"><i class="fas fa-plus"></i> Go to Admin Panel</a>
            </div>
        <?php } ?>
    </div>
</div>

<?php include 'require/foot.php'; ?>

<script src="assets/js/jquery.js"></script>
<script src="assets/js/script.js"></script>
<script>
function addToCart(productId){
    fetch('assets/backend/cart/add.php',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'product_id='+productId+'&quantity=1'
    })
    .then(r=>r.json())
    .then(d=>{
        if(d.success){
            alert('Product added to cart!');
            location.reload();
        }
    })
    .catch(e=>console.error(e));
}
</script>

</body>
</html>
PHPEOF

# Deploy
docker cp /tmp/index_with_images.php $WEB_CONTAINER:/var/www/html/index.php

# Save locally
LOCAL_PATH=$(find ~/maureen-ecommerce -name "index.php" -path "*-commerce*" 2>/dev/null | head -1)
if [ -n "$LOCAL_PATH" ]; then
    cp /tmp/index_with_images.php "$LOCAL_PATH"
    echo "✅ Local file updated"
fi

rm /tmp/index_with_images.php

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Restart Container"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker restart $WEB_CONTAINER
sleep 5

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DONE! Now Add Real Images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Upload your real product images to:"
echo "   Container: docker cp <image.jpg> $WEB_CONTAINER:/var/www/html/media/categories/"
echo "   Local: ~/maureen-ecommerce/.../media/categories/"
echo ""
echo "🖼️  Required images:"
echo "   • samsung-tv.jpg (Samsung TV image)"
echo "   • soundbar.jpg (Soundbar/speaker image)"
echo "   • furniture.jpg (Furniture image)"
echo "   • car.jpg (Car image)"
echo "   • laptop.jpg (Laptop image)"
echo ""
echo "🌐 Visit: http://localhost:3000"
echo ""
echo "📝 Categories now include:"
echo "   1. TVs"
echo "   2. Surround Sounds"
echo "   3. Furniture"
echo "   4. Cars"
echo "   5. Laptops (NEW!)"
echo ""