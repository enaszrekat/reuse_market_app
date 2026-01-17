import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
  int _userId = 0;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  CartService() {
    _loadCart();
  }

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ Always reload user_id to ensure it's current
      _userId = prefs.getInt("user_id") ?? 0;
      
      final cartJson = prefs.getString("cart_$_userId");
      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }
  
  // ✅ Public method to reload user_id (call after login/logout)
  Future<void> reloadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt("user_id") ?? 0;
    await _loadCart(); // Reload cart for new user
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString("cart_$_userId", cartJson);
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }

  // Add product to cart
  Future<bool> addItem({
    required int productId,
    required String title,
    required String imageUrl,
    required double price,
    required int productOwnerId,
  }) async {
    // ✅ Reload user_id from SharedPreferences to ensure it's current
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt("user_id");
    
    // ✅ Only block if currentUserId is not null AND it matches productOwnerId
    // ✅ If currentUserId is null (not logged in), allow adding to cart
    if (currentUserId != null && currentUserId > 0 && productOwnerId == currentUserId) {
      return false; // Cannot add own product
    }

    // Check if product already exists in cart
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    
    if (existingIndex != -1) {
      // Increase quantity if product exists
      _items[existingIndex].quantity++;
    } else {
      // Add new item
      _items.add(CartItem(
        productId: productId,
        title: title,
        imageUrl: imageUrl,
        price: price,
        quantity: 1,
      ));
    }

    await _saveCart();
    notifyListeners();
    return true;
  }

  // Remove item from cart
  Future<void> removeItem(int productId) async {
    _items.removeWhere((item) => item.productId == productId);
    await _saveCart();
    notifyListeners();
  }

  // Update quantity
  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _items[index].quantity = quantity;
      await _saveCart();
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Get quantity of a product in cart
  int getQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        productId: 0,
        title: '',
        imageUrl: '',
        price: 0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}

