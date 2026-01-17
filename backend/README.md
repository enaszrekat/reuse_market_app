# Backend PHP Files

These PHP files should be placed in your XAMPP `htdocs/market_app/` directory.

## Setup Instructions

1. Copy all PHP files to: `C:\xampp\htdocs\market_app\` (or your XAMPP installation path)

2. Update database credentials in each PHP file:
   - `$host = "localhost";`
   - `$dbname = "market_app";` (change to your database name)
   - `$username = "root";` (change to your database username)
   - `$password = "";` (change to your database password)

3. Ensure your database has the following tables:
   - `users` (with columns: id, name, username, email, country, account_type/role)
   - `products` (with columns: id, title, description, price, type, status, user_id, created_at)
   - `product_images` (with columns: id, product_id, image_name)

## API Endpoints

### get_user_products.php
- **Method**: POST
- **Parameters**: `user_id` (POST)
- **Returns**: JSON with user's products including images array

### get_user.php
- **Method**: POST
- **Parameters**: `user_id` (POST)
- **Returns**: JSON with user information (name, email, country, account_type)

### get_products.php
- **Method**: GET
- **Returns**: JSON with all approved products including images array

### get_approved_products.php
- **Method**: GET
- **Returns**: JSON with all approved products (same as get_products.php)

## Response Format

All endpoints return JSON in this format:

```json
{
  "status": "success" | "error",
  "message": "Error message (if error)",
  "products": [...],  // For product endpoints
  "user": {...}        // For user endpoint
}
```

## Important Notes

- All endpoints set proper JSON headers
- All endpoints handle errors gracefully
- All endpoints return valid JSON (no HTML errors)
- Database errors are caught and returned as JSON
- All endpoints support CORS for Flutter app

