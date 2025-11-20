import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;

class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory User.fromRow(Map<String, dynamic> row) {
    return User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      phone: row['phone'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
    );
  }
}

class Product {
  final int? id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String category;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] as String,
    );
  }

  factory Product.fromRow(Map<String, dynamic> row) {
    return Product(
      id: row['id'] as int,
      title: row['title'] as String,
      description: row['description'] as String,
      price: (row['price'] as num).toDouble(),
      stock: row['stock'] as int,
      category: row['category'] as String,
    );
  }
}

class Order {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final double totalAmount;
  final String status;
  final DateTime orderDate;

  Order({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'] as String)
          : DateTime.now(),
    );
  }

  factory Order.fromRow(Map<String, dynamic> row) {
    return Order(
      id: row['id'] as int,
      userId: row['userId'] as int,
      productId: row['productId'] as int,
      quantity: row['quantity'] as int,
      totalAmount: (row['totalAmount'] as num).toDouble(),
      status: row['status'] as String,
      orderDate: DateTime.parse(row['orderDate'] as String),
    );
  }
}

class DatabaseService {
  late Database db;

  DatabaseService() {
    final dbPath = path.join(Directory.current.path, 'app_database.db');
    db = sqlite3.open(dbPath);
    _initializeDatabase();
  }

  void _initializeDatabase() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
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
    ''');
  }

  List<User> getAllUsers() {
    final result = db.select('SELECT * FROM users ORDER BY id DESC');
    return result.map((row) {
      return User.fromRow({
        'id': row['id'],
        'name': row['name'],
        'email': row['email'],
        'phone': row['phone'],
        'createdAt': row['createdAt'],
      });
    }).toList();
  }

  User? getUserById(int id) {
    final result = db.select('SELECT * FROM users WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    final row = result.first;
    return User.fromRow({
      'id': row['id'],
      'name': row['name'],
      'email': row['email'],
      'phone': row['phone'],
      'createdAt': row['createdAt'],
    });
  }

  User createUser(User user) {
    final stmt = db.prepare('''
      INSERT INTO users (name, email, phone, createdAt)
      VALUES (?, ?, ?, ?)
    ''');
    stmt.execute([
      user.name,
      user.email,
      user.phone,
      user.createdAt.toIso8601String(),
    ]);
    final id = db.lastInsertRowId;
    stmt.dispose();
    return User(
      id: id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      createdAt: user.createdAt,
    );
  }

  User? updateUser(int id, User user) {
    final existing = getUserById(id);
    if (existing == null) return null;
    final stmt = db.prepare('''
      UPDATE users
      SET name = ?, email = ?, phone = ?
      WHERE id = ?
    ''');
    stmt.execute([user.name, user.email, user.phone, id]);
    stmt.dispose();
    return User(
      id: id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      createdAt: existing.createdAt,
    );
  }

  bool deleteUser(int id) {
    final existing = getUserById(id);
    if (existing == null) return false;
    final stmt = db.prepare('DELETE FROM users WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
    return true;
  }

  List<Product> getAllProducts() {
    final result = db.select('SELECT * FROM products ORDER BY id DESC');
    return result.map((row) {
      return Product.fromRow({
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'price': row['price'],
        'stock': row['stock'],
        'category': row['category'],
      });
    }).toList();
  }

  Product? getProductById(int id) {
    final result = db.select('SELECT * FROM products WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    final row = result.first;
    return Product.fromRow({
      'id': row['id'],
      'title': row['title'],
      'description': row['description'],
      'price': row['price'],
      'stock': row['stock'],
      'category': row['category'],
    });
  }

  Product createProduct(Product product) {
    final stmt = db.prepare('''
      INSERT INTO products (title, description, price, stock, category)
      VALUES (?, ?, ?, ?, ?)
    ''');
    stmt.execute([
      product.title,
      product.description,
      product.price,
      product.stock,
      product.category,
    ]);
    final id = db.lastInsertRowId;
    stmt.dispose();
    return Product(
      id: id,
      title: product.title,
      description: product.description,
      price: product.price,
      stock: product.stock,
      category: product.category,
    );
  }

  Product? updateProduct(int id, Product product) {
    final existing = getProductById(id);
    if (existing == null) return null;
    final stmt = db.prepare('''
      UPDATE products
      SET title = ?, description = ?, price = ?, stock = ?, category = ?
      WHERE id = ?
    ''');
    stmt.execute([
      product.title,
      product.description,
      product.price,
      product.stock,
      product.category,
      id,
    ]);
    stmt.dispose();
    return Product(
      id: id,
      title: product.title,
      description: product.description,
      price: product.price,
      stock: product.stock,
      category: product.category,
    );
  }

  bool deleteProduct(int id) {
    final existing = getProductById(id);
    if (existing == null) return false;
    final stmt = db.prepare('DELETE FROM products WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
    return true;
  }

  List<Order> getAllOrders() {
    final result = db.select('SELECT * FROM orders ORDER BY id DESC');
    return result.map((row) {
      return Order.fromRow({
        'id': row['id'],
        'userId': row['userId'],
        'productId': row['productId'],
        'quantity': row['quantity'],
        'totalAmount': row['totalAmount'],
        'status': row['status'],
        'orderDate': row['orderDate'],
      });
    }).toList();
  }

  Order? getOrderById(int id) {
    final result = db.select('SELECT * FROM orders WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    final row = result.first;
    return Order.fromRow({
      'id': row['id'],
      'userId': row['userId'],
      'productId': row['productId'],
      'quantity': row['quantity'],
      'totalAmount': row['totalAmount'],
      'status': row['status'],
      'orderDate': row['orderDate'],
    });
  }

  Order createOrder(Order order) {
    final stmt = db.prepare('''
      INSERT INTO orders (userId, productId, quantity, totalAmount, status, orderDate)
      VALUES (?, ?, ?, ?, ?, ?)
    ''');
    stmt.execute([
      order.userId,
      order.productId,
      order.quantity,
      order.totalAmount,
      order.status,
      order.orderDate.toIso8601String(),
    ]);
    final id = db.lastInsertRowId;
    stmt.dispose();
    return Order(
      id: id,
      userId: order.userId,
      productId: order.productId,
      quantity: order.quantity,
      totalAmount: order.totalAmount,
      status: order.status,
      orderDate: order.orderDate,
    );
  }

  Order? updateOrder(int id, Order order) {
    final existing = getOrderById(id);
    if (existing == null) return null;
    final stmt = db.prepare('''
      UPDATE orders
      SET userId = ?, productId = ?, quantity = ?, totalAmount = ?, status = ?
      WHERE id = ?
    ''');
    stmt.execute([
      order.userId,
      order.productId,
      order.quantity,
      order.totalAmount,
      order.status,
      id,
    ]);
    stmt.dispose();
    return Order(
      id: id,
      userId: order.userId,
      productId: order.productId,
      quantity: order.quantity,
      totalAmount: order.totalAmount,
      status: order.status,
      orderDate: existing.orderDate,
    );
  }

  bool deleteOrder(int id) {
    final existing = getOrderById(id);
    if (existing == null) return false;
    final stmt = db.prepare('DELETE FROM orders WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
    return true;
  }

  void close() {
    db.dispose();
  }
}

class UserHandler {
  final DatabaseService dbService;

  UserHandler(this.dbService);

  Map<String, String> get _headers => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json',
      };

  Future<Response> getAllUsers(Request request) async {
    try {
      final users = dbService.getAllUsers();
      return Response.ok(
        jsonEncode({'success': true, 'data': users.map((u) => u.toJson()).toList()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> getUserById(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid user ID'}),
          headers: _headers,
        );
      }
      final user = dbService.getUserById(userId);
      if (user == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: _headers,
        );
      }
      return Response.ok(
        jsonEncode({'success': true, 'data': user.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> createUser(Request request) async {
    try {
      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      if (!jsonData.containsKey('name') ||
          !jsonData.containsKey('email') ||
          !jsonData.containsKey('phone')) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Missing required fields: name, email, phone'}),
          headers: _headers,
        );
      }

      final user = User.fromJson({
        ...jsonData,
        'createdAt': DateTime.now().toIso8601String(),
      });
      final createdUser = dbService.createUser(user);
      
      return Response.ok(
        jsonEncode({'success': true, 'data': createdUser.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> updateUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid user ID'}),
          headers: _headers,
        );
      }

      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      if (!jsonData.containsKey('name') ||
          !jsonData.containsKey('email') ||
          !jsonData.containsKey('phone')) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Missing required fields: name, email, phone'}),
          headers: _headers,
        );
      }

      final existing = dbService.getUserById(userId);
      if (existing == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: _headers,
        );
      }

      final user = User.fromJson({
        ...jsonData,
        'createdAt': existing.createdAt.toIso8601String(),
      });
      final updatedUser = dbService.updateUser(userId, user);
      
      return Response.ok(
        jsonEncode({'success': true, 'data': updatedUser!.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> deleteUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid user ID'}),
          headers: _headers,
        );
      }

      final deleted = dbService.deleteUser(userId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({'success': true, 'message': 'User deleted successfully'}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }
}

class ProductHandler {
  final DatabaseService dbService;

  ProductHandler(this.dbService);

  Map<String, String> get _headers => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json',
      };

  Future<Response> getAllProducts(Request request) async {
    try {
      final products = dbService.getAllProducts();
      return Response.ok(
        jsonEncode({'success': true, 'data': products.map((p) => p.toJson()).toList()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> getProductById(Request request, String id) async {
    try {
      final productId = int.tryParse(id);
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid product ID'}),
          headers: _headers,
        );
      }
      final product = dbService.getProductById(productId);
      if (product == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Product not found'}),
          headers: _headers,
        );
      }
      return Response.ok(
        jsonEncode({'success': true, 'data': product.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> createProduct(Request request) async {
    try {
      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      if (!jsonData.containsKey('title') ||
          !jsonData.containsKey('description') ||
          !jsonData.containsKey('price') ||
          !jsonData.containsKey('stock') ||
          !jsonData.containsKey('category')) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Missing required fields: title, description, price, stock, category'}),
          headers: _headers,
        );
      }

      final product = Product.fromJson(jsonData);
      final createdProduct = dbService.createProduct(product);
      
      return Response.ok(
        jsonEncode({'success': true, 'data': createdProduct.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> updateProduct(Request request, String id) async {
    try {
      final productId = int.tryParse(id);
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid product ID'}),
          headers: _headers,
        );
      }

      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      if (!jsonData.containsKey('title') ||
          !jsonData.containsKey('description') ||
          !jsonData.containsKey('price') ||
          !jsonData.containsKey('stock') ||
          !jsonData.containsKey('category')) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Missing required fields: title, description, price, stock, category'}),
          headers: _headers,
        );
      }

      final product = Product.fromJson(jsonData);
      final updatedProduct = dbService.updateProduct(productId, product);
      
      if (updatedProduct == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Product not found'}),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({'success': true, 'data': updatedProduct.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> deleteProduct(Request request, String id) async {
    try {
      final productId = int.tryParse(id);
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid product ID'}),
          headers: _headers,
        );
      }

      final deleted = dbService.deleteProduct(productId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Product not found'}),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Product deleted successfully'}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }
}

class OrderHandler {
  final DatabaseService dbService;

  OrderHandler(this.dbService);

  Map<String, String> get _headers => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json',
      };

  Future<Response> getAllOrders(Request request) async {
    try {
      final orders = dbService.getAllOrders();
      return Response.ok(
        jsonEncode({'success': true, 'data': orders.map((o) => o.toJson()).toList()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> getOrderById(Request request, String id) async {
    try {
      final orderId = int.tryParse(id);
      if (orderId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid order ID'}),
          headers: _headers,
        );
      }
      final order = dbService.getOrderById(orderId);
      if (order == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Order not found'}),
          headers: _headers,
        );
      }
      return Response.ok(
        jsonEncode({'success': true, 'data': order.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> createOrder(Request request) async {
    try {
      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      if (!jsonData.containsKey('userId') ||
          !jsonData.containsKey('productId') ||
          !jsonData.containsKey('quantity') ||
          !jsonData.containsKey('totalAmount') ||
          !jsonData.containsKey('status')) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Missing required fields: userId, productId, quantity, totalAmount, status'}),
          headers: _headers,
        );
      }

      final order = Order.fromJson({
        ...jsonData,
        'orderDate': DateTime.now().toIso8601String(),
      });
      final createdOrder = dbService.createOrder(order);
      
      return Response.ok(
        jsonEncode({'success': true, 'data': createdOrder.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> updateOrder(Request request, String id) async {
    try {
      final orderId = int.tryParse(id);
      if (orderId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid order ID'}),
          headers: _headers,
        );
      }

      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      if (!jsonData.containsKey('userId') ||
          !jsonData.containsKey('productId') ||
          !jsonData.containsKey('quantity') ||
          !jsonData.containsKey('totalAmount') ||
          !jsonData.containsKey('status')) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Missing required fields: userId, productId, quantity, totalAmount, status'}),
          headers: _headers,
        );
      }

      final existing = dbService.getOrderById(orderId);
      if (existing == null) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Order not found'}),
          headers: _headers,
        );
      }

      final order = Order.fromJson({
        ...jsonData,
        'orderDate': existing.orderDate.toIso8601String(),
      });
      final updatedOrder = dbService.updateOrder(orderId, order);
      
      return Response.ok(
        jsonEncode({'success': true, 'data': updatedOrder!.toJson()}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> deleteOrder(Request request, String id) async {
    try {
      final orderId = int.tryParse(id);
      if (orderId == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'Invalid order ID'}),
          headers: _headers,
        );
      }

      final deleted = dbService.deleteOrder(orderId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'Order not found'}),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Order deleted successfully'}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _headers,
      );
    }
  }
}

Router buildRouter(UserHandler userHandler, ProductHandler productHandler, OrderHandler orderHandler) {
  final router = Router();

  router.get('/api/user/getAllUsers', userHandler.getAllUsers);
  router.get('/api/user/getUser/<id>', (Request request, String id) => userHandler.getUserById(request, id));
  router.post('/api/user/createUser', userHandler.createUser);
  router.put('/api/user/updateUser/<id>', (Request request, String id) => userHandler.updateUser(request, id));
  router.delete('/api/user/deleteUser/<id>', (Request request, String id) => userHandler.deleteUser(request, id));

  router.get('/api/product/getAllProducts', productHandler.getAllProducts);
  router.get('/api/product/getProduct/<id>', (Request request, String id) => productHandler.getProductById(request, id));
  router.post('/api/product/createProduct', productHandler.createProduct);
  router.put('/api/product/updateProduct/<id>', (Request request, String id) => productHandler.updateProduct(request, id));
  router.delete('/api/product/deleteProduct/<id>', (Request request, String id) => productHandler.deleteProduct(request, id));

  router.get('/api/order/getAllOrders', orderHandler.getAllOrders);
  router.get('/api/order/getOrder/<id>', (Request request, String id) => orderHandler.getOrderById(request, id));
  router.post('/api/order/createOrder', orderHandler.createOrder);
  router.put('/api/order/updateOrder/<id>', (Request request, String id) => orderHandler.updateOrder(request, id));
  router.delete('/api/order/deleteOrder/<id>', (Request request, String id) => orderHandler.deleteOrder(request, id));

  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound(
      jsonEncode({'success': false, 'error': 'Route not found'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}

void main() async {
  final dbService = DatabaseService();
  final userHandler = UserHandler(dbService);
  final productHandler = ProductHandler(dbService);
  final orderHandler = OrderHandler(dbService);
  final router = buildRouter(userHandler, productHandler, orderHandler);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  
  print('Server running on http://${server.address.host}:${server.port}');
  print('');
  print('User Endpoints:');
  print('  GET    /api/user/getAllUsers - Get all users');
  print('  GET    /api/user/getUser/<id> - Get user by ID');
  print('  POST   /api/user/createUser - Create a new user');
  print('  PUT    /api/user/updateUser/<id> - Update a user');
  print('  DELETE /api/user/deleteUser/<id> - Delete a user');
  print('');
  print('Product Endpoints:');
  print('  GET    /api/product/getAllProducts - Get all products');
  print('  GET    /api/product/getProduct/<id> - Get product by ID');
  print('  POST   /api/product/createProduct - Create a new product');
  print('  PUT    /api/product/updateProduct/<id> - Update a product');
  print('  DELETE /api/product/deleteProduct/<id> - Delete a product');
  print('');
  print('Order Endpoints:');
  print('  GET    /api/order/getAllOrders - Get all orders');
  print('  GET    /api/order/getOrder/<id> - Get order by ID');
  print('  POST   /api/order/createOrder - Create a new order');
  print('  PUT    /api/order/updateOrder/<id> - Update an order');
  print('  DELETE /api/order/deleteOrder/<id> - Delete an order');
}
