import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/custom_appbar.dart';
import 'history_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // =========================
  // 📦 STATE
  // =========================
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;

  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // =========================
  // 📦 LOAD PRODUCTS
  // =========================
  Future<void> _loadProducts() async {
    try {
      final data = await ApiService.getProducts();

      setState(() {
        _allProducts = data;
        _filteredProducts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // =========================
  // 🔍 SEARCH
  // =========================
  void _searchProducts(String query) {
    final q = query.toLowerCase();

    final results = _allProducts.where((product) {
      final name = product.name.toLowerCase();
      final brand = (product.brand ?? "").toLowerCase();
      return name.contains(q) || brand.contains(q);
    }).toList();

    setState(() => _filteredProducts = results);
  }

  // =========================
  // 🔎 FETCH SUGGESTIONS
  // =========================
  void _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final results = await ApiService.searchProducts(query);
      setState(() {
        _suggestions = results;
        _showSuggestions = true;
      });
    } catch (_) {}
  }

  // =========================
  // 🧱 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showSuggestions = false),
      child: Scaffold(
        appBar: const CustomAppBar(title: "Inventory"),

        // ➕ ADD PRODUCT (OWNER ONLY)
        floatingActionButton: ApiService.getRole() == "owner"
            ? FloatingActionButton(
                onPressed: _showAddProductDialog,
                child: const Icon(Icons.add),
              )
            : null,

        body: Column(
          children: [
            // =========================
            // 🔍 SEARCH BAR
            // =========================
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _searchProducts(value);
                  _fetchSuggestions(value);
                },
              ),
            ),

            // =========================
            // 🔥 SUGGESTIONS DROPDOWN
            // =========================
            if (_showSuggestions)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (_, index) {
                    final item = _suggestions[index];

                    return ListTile(
                      title: Text(item["name"]),
                      subtitle: Text(item["brand"] ?? ""),
                      onTap: () {
                        setState(() => _showSuggestions = false);

                        _showAddProductDialog(
                          prefillName: item["name"],
                          prefillBrand: item["brand"] ?? "",
                        );
                      },
                    );
                  },
                ),
              ),

            // =========================
            // 📄 PRODUCT LIST
            // =========================
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(child: Text("Error: $_error"))
                      : _filteredProducts.isEmpty
                          ? const Center(child: Text("No products found"))
                          : ListView.builder(
                              itemCount: _filteredProducts.length,
                              itemBuilder: (_, index) {
                                final product = _filteredProducts[index];

                                return Card(
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(product.name),

                                    // =========================
                                    // 📄 PRODUCT DETAILS
                                    // =========================
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (product.brand != null &&
                                            product.brand!.isNotEmpty)
                                          Text(product.brand!),

                                        Text("₹${product.price}"),
                                        Text("Stock: ${product.stock}"),

                                        const SizedBox(height: 8),

                                        // 📩 REQUEST BUTTON (MANAGER)
                                        if (ApiService.getRole() == "manager")
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: product.stock == 0
                                                ? null
                                                : () {
                                                    _showRequestDialog(
                                                        product.id);
                                                  },
                                            icon: const Icon(Icons.send,
                                                size: 18),
                                            label: const Text("Request"),
                                          ),
                                      ],
                                    ),

                                    // =========================
                                    // ⚙️ ACTIONS
                                    // =========================
                                    trailing: Wrap(
                                      spacing: 6,
                                      children: [
                                        if (product.stock < 5)
                                          const Icon(Icons.warning,
                                              color: Colors.red),

                                        // 📜 HISTORY
                                        IconButton(
                                          icon: const Icon(Icons.history),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => HistoryScreen(
                                                    productId: product.id),
                                              ),
                                            );
                                          },
                                        ),

                                        // 👑 OWNER ACTIONS
                                        if (ApiService.getRole() ==
                                            "owner") ...[
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _showAddProductDialog(
                                                  product: product);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              _confirmDelete(product.id,
                                                  product.name);
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ❌ DELETE PRODUCT
  // =========================
  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Delete '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.deleteProduct(id);
              _loadProducts();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // =========================
  // ➕ ADD / EDIT PRODUCT
  // =========================
  void _showAddProductDialog({
    Product? product,
    String? prefillName,
    String? prefillBrand,
  }) {
    final nameController =
        TextEditingController(text: product?.name ?? prefillName ?? "");
    final brandController =
        TextEditingController(text: product?.brand ?? prefillBrand ?? "");
    final priceController = TextEditingController(
      text: product != null ? product.price.toString() : "",
    );
    final stockController = TextEditingController(
      text: product != null ? product.stock.toString() : "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product != null ? "Edit Product" : "Add Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: "Brand"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final brand = brandController.text.trim();
              final price = int.tryParse(priceController.text);
              final stock = int.tryParse(stockController.text);

              if (name.isEmpty || price == null || stock == null) return;

              Map<String, dynamic> result;

              if (product != null) {
                // ✏️ EDIT MODE
                result = await ApiService.updateProduct(
                  id: product.id,
                  name: name,
                  brand: brand,
                  price: price,
                  stock: stock,
                );
              } else {
                // ➕ ADD MODE
                result = await ApiService.addProduct(
                  name: name,
                  brand: brand,
                  price: price,
                  stock: stock,
                );
              }

              if (!mounted) return;

              Navigator.pop(context);
              _loadProducts();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result["message"])),
              );
            },
            child: Text(product != null ? "Update" : "Save"),
          ),
        ],
      ),
    );
  }

  // =========================
  // 📩 REQUEST STOCK
  // =========================
  void _showRequestDialog(int productId) {
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Request Stock"),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text);
              if (qty == null || qty <= 0) return;

              await ApiService.createRequest(
                productId: productId,
                quantity: qty,
              );

              if (!mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Request sent")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}