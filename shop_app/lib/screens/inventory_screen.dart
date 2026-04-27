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
  // LOCAL SEARCH
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
  // API SUGGESTIONS
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
                hintText: "Search products (name / brand)...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchProducts(value);
                _fetchSuggestions(value);
              },
            ),
          ),

          // 🔥 SUGGESTIONS
          if (_showSuggestions)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
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
                      _searchProducts(item["name"]);
                      setState(() => _showSuggestions = false);
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
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredProducts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, index) {
                                final product =
                                    _filteredProducts[index];

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // LEFT
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style:
                                                  const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            if (product.brand != null &&
                                                product.brand!
                                                    .isNotEmpty)
                                              Text(
                                                product.brand!,
                                                style:
                                                    const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),

                                            const SizedBox(height: 4),

                                            Text(
                                                "₹${product.price}"),

                                            Text(
                                              "Stock: ${product.stock}",
                                              style: TextStyle(
                                                color: product.stock < 5
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),

                                            // MANAGER BUTTON
                                            if (ApiService.role ==
                                                "manager") ...[
                                              const SizedBox(
                                                  height: 8),
                                              ElevatedButton.icon(
                                                onPressed:
                                                    product.stock ==
                                                            0
                                                        ? null
                                                        : () {
                                                            _showRequestDialog(
                                                                product
                                                                    .id);
                                                          },
                                                icon: const Icon(
                                                    Icons.send,
                                                    size: 18),
                                                label: const Text(
                                                    "Request"),
                                              ),
                                            ],
                                          ],
                                        ),

                                        // RIGHT
                                        Row(
                                          children: [
                                            if (product.stock < 5)
                                              const Icon(
                                                Icons.warning,
                                                color: Colors.red,
                                              ),

                                            if (ApiService.role ==
                                                "owner")
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete,
                                                    color:
                                                        Colors.red),
                                                onPressed: () {
                                                  _confirmDelete(
                                                    product.id,
                                                    product.name,
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
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
              decoration:
                  const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: "Brand",
                hintText: "Crocin / Loose / Generic",
              ),
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
                  const SnackBar(
                      content: Text("Enter valid data")),
                );
                return;
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
  // REQUEST STOCK
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
          decoration:
              const InputDecoration(labelText: "Quantity"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
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