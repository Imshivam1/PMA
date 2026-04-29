import '../models/product.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_appbar.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
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
  // LOAD PRODUCTS
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
  // SEARCH
  // =========================
  void _searchProducts(String query) {
    final q = query.toLowerCase();

    final results = _allProducts.where((product) {
      final name = product.name.toLowerCase();
      final brand = (product.brand ?? "").toLowerCase();
      return name.contains(q) || brand.contains(q);
    }).toList();

    setState(() {
      _filteredProducts = results;
    });
  }

  // =========================
  // FIND EXISTING PRODUCT
  // =========================
  Product? _findExistingProduct(String name, String brand) {
    try {
      return _allProducts.firstWhere(
        (p) =>
            p.name.toLowerCase() == name.toLowerCase() &&
            (p.brand ?? "").toLowerCase() == brand.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // =========================
  // FETCH SUGGESTIONS
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Inventory"),

      floatingActionButton: ApiService.role == "owner"
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: const Icon(Icons.add),
            )
          : null,

      body: Column(
        children: [
          // 🔍 SEARCH BAR
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

          // 🔥 SUGGESTIONS DROPDOWN
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
                shrinkWrap: true,
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
          // PRODUCT LIST
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
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (product.brand != null &&
                                          product.brand!.isNotEmpty)
                                        Text(product.brand!),
                                      Text("₹${product.price}"),
                                      Text("Stock: ${product.stock}"),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (product.stock < 5)
                                        const Icon(Icons.warning,
                                            color: Colors.red),

                                      if (ApiService.role == "owner")
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _confirmDelete(
                                                product.id,
                                                product.name);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // =========================
  // DELETE
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
  // ADD PRODUCT
  // =========================
  void _showAddProductDialog({
    String? prefillName,
    String? prefillBrand,
  }) {
    final nameController =
        TextEditingController(text: prefillName ?? "");
    final brandController =
        TextEditingController(text: prefillBrand ?? "");
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              readOnly: prefillName != null,
              decoration:
                  const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: brandController,
              readOnly: prefillBrand != null,
              decoration:
                  const InputDecoration(labelText: "Brand"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Stock"),
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

              if (name.isEmpty ||
                  price == null ||
                  stock == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter valid data")),
                );
                return;
              }

              final existing = _findExistingProduct(name, brand);

              if (existing != null) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Product Exists"),
                    content: Text(
                      "'$name (${brand.isEmpty ? "No Brand" : brand}) already exists.\n\nUpdate stock instead?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Update"),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;
              }

              final result = await ApiService.addProduct(
                name: name,
                brand: brand,
                price: price,
                stock: stock,
              );

              if (!mounted) return;

              Navigator.pop(context);
              _loadProducts();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result["message"])),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // =========================
  // REQUEST
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