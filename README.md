# Dart Backend - E-commerce REST API

A complete REST API backend built with **Dart**, **Shelf**, and **SQLite3** for managing Users, Products, and Orders in an e-commerce application.

**Created by:** Jaydip Sakhiya

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Server](#running-the-server)
- [API Documentation](#api-documentation)
- [Postman Collection](#postman-collection)
- [API Endpoints](#api-endpoints)
- [Database Schema](#database-schema)
- [Example Requests](#example-requests)
- [Project Structure](#project-structure)

---

## ✨ Features

- **User Management**: Complete CRUD operations for user accounts
- **Product Management**: Full product catalog management
- **Order Management**: Order creation, tracking, and management
- **SQLite Database**: Lightweight, file-based database
- **RESTful API**: Clean and intuitive REST endpoints
- **CORS Enabled**: Ready for frontend integration
- **Error Handling**: Comprehensive error responses

---

## 🛠 Tech Stack

- **Dart** - Programming language
- **Shelf** - Web server framework
- **Shelf Router** - HTTP routing
- **SQLite3** - Database engine
- **Path** - Path manipulation utilities

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- **Dart SDK** (version 3.6.0 or higher)
  - Download from: [https://dart.dev/get-dart](https://dart.dev/get-dart)
- **Postman** (optional, for API testing)
  - Download from: [https://www.postman.com/downloads/](https://www.postman.com/downloads/)

---

## 🚀 Installation

1. **Clone or download this repository**

2. **Install dependencies:**
   ```bash
   dart pub get
   ```

3. **Verify installation:**
   ```bash
   dart --version
   ```

---

## ▶️ Running the Server

1. **Start the server:**
   ```bash
   dart run lib/main.dart
   ```

2. **Or set a custom port (default is 8080):**
   ```bash
   PORT=3000 dart run lib/main.dart
   ```

3. **Server will start and display:**
   ```
   Server running on http://0.0.0.0:8080
   
   User Endpoints:
     GET    /api/user/getAllUsers
     GET    /api/user/getUser/<id>
     POST   /api/user/createUser
     PUT    /api/user/updateUser/<id>
     DELETE /api/user/deleteUser/<id>
   
   Product Endpoints:
     GET    /api/product/getAllProducts
     GET    /api/product/getProduct/<id>
     POST   /api/product/createProduct
     PUT    /api/product/updateProduct/<id>
     DELETE /api/product/deleteProduct/<id>
   
   Order Endpoints:
     GET    /api/order/getAllOrders
     GET    /api/order/getOrder/<id>
     POST   /api/order/createOrder
     PUT    /api/order/updateOrder/<id>
     DELETE /api/order/deleteOrder/<id>
   ```

4. **The database file (`app_database.db`) will be automatically created in the project root directory.**

---

## 📚 API Documentation

### Base URL

- **Local:** `http://localhost:8080`
- **Network:** `http://YOUR_IP_ADDRESS:8080` (for testing from other devices)

### Response Format

All API responses follow this structure:

**Success Response:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message here"
}
```

---

## 🚀 Postman Collection

**The easiest way to test all APIs is by importing the provided Postman collection!**

### How to Import and Use:

1. **Open Postman** application

2. **Import the Collection:**
   - Click **"Import"** button (top left)
   - Select **"File"** tab
   - Choose `lib/postman_collection.json` from this project
   - Click **"Import"**

3. **Set Base URL:**
   - The collection includes a variable `baseUrl` set to `http://localhost:8080`
   - To change it:
     - Click on the collection name
     - Go to **"Variables"** tab
     - Update `baseUrl` value (e.g., `http://192.168.1.100:8080` for network access)
     - Click **"Save"**

4. **Start Testing:**
   - Make sure your server is running
   - All endpoints are pre-configured and ready to use
   - Just click **"Send"** on any request!

### Benefits of Using Postman Collection:

✅ **Pre-configured requests** - No need to manually set up each endpoint  
✅ **Example payloads** - Sample JSON bodies included  
✅ **Organized structure** - Requests grouped by Users, Products, Orders  
✅ **Easy testing** - Test all APIs with one click  
✅ **Save time** - Import and start testing immediately  

---

## 📡 API Endpoints

### 👤 User Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/user/getAllUsers` | Get all users |
| GET | `/api/user/getUser/{id}` | Get user by ID |
| POST | `/api/user/createUser` | Create a new user |
| PUT | `/api/user/updateUser/{id}` | Update a user |
| DELETE | `/api/user/deleteUser/{id}` | Delete a user |

### 📦 Product Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/product/getAllProducts` | Get all products |
| GET | `/api/product/getProduct/{id}` | Get product by ID |
| POST | `/api/product/createProduct` | Create a new product |
| PUT | `/api/product/updateProduct/{id}` | Update a product |
| DELETE | `/api/product/deleteProduct/{id}` | Delete a product |

### 🛒 Order Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/order/getAllOrders` | Get all orders |
| GET | `/api/order/getOrder/{id}` | Get order by ID |
| POST | `/api/order/createOrder` | Create a new order |
| PUT | `/api/order/updateOrder/{id}` | Update an order |
| DELETE | `/api/order/deleteOrder/{id}` | Delete an order |

---

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
```

### Products Table
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL,
  category TEXT NOT NULL
)
```

### Orders Table
```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,
  productId INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  totalAmount REAL NOT NULL,
  status TEXT NOT NULL,
  orderDate TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users(id),
  FOREIGN KEY (productId) REFERENCES products(id)
)
```

---

## 💡 Example Requests

### Create a User

**POST** `/api/user/createUser`

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### Create a Product

**POST** `/api/product/createProduct`

```json
{
  "title": "Laptop Pro",
  "description": "High-performance laptop",
  "price": 1299.99,
  "stock": 15,
  "category": "Electronics"
}
```

### Create an Order

**POST** `/api/order/createOrder`

```json
{
  "userId": 1,
  "productId": 2,
  "quantity": 3,
  "totalAmount": 389.97,
  "status": "pending"
}
```

**Note:** `orderDate` is automatically set to the current timestamp.

---

## 📁 Project Structure

```
dart_backend/
├── lib/
│   ├── main.dart                 # Main server file with all handlers
│   └── postman_collection.json   # Postman collection for API testing
├── app_database.db               # SQLite database (auto-generated)
├── pubspec.yaml                  # Dart dependencies
├── README.md                     # This file
└── ...
```

---

## 🔧 Troubleshooting

### Port Already in Use
If port 8080 is already in use:
```bash
PORT=3000 dart run lib/main.dart
```

### Database Issues
- Delete `app_database.db` to reset the database
- The database will be recreated automatically on next server start

### CORS Issues
- CORS is already enabled for all origins (`*`)
- If you face issues, check your frontend CORS configuration

---

## 📝 Notes

- The database file (`app_database.db`) is created automatically in the project root
- All timestamps are stored in ISO 8601 format
- Email addresses must be unique for users
- Foreign key constraints are enforced for orders (userId and productId must exist)

---

## 👨‍💻 Author

**Jaydip Sakhiya**

---

## 📄 License

This project is open source and available for use.

---

## 🤝 Contributing

Feel free to fork this project and submit pull requests for any improvements!

---

**Happy Coding! 🚀**
