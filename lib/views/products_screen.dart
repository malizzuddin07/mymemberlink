import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/new_products.dart';
import 'package:my_member_link/views/edit_products.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List products = [];
  List filteredProducts = [];
  List cart = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(
          "${MyConfig.servername}/memberlink/api/load_products.php?pageno=$currentPage"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success") {
          setState(() {
            products = data['data'];
            filteredProducts = List.from(products);
            totalPages = data['numofpage'];
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void addToCart(Map product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product added to cart!")),
    );
  }

  void showProductDetails(Map product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product['product_name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network("${MyConfig.servername}/${product['product_image']}",
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image)),
            Text(product['product_description']),
            Text("Price: RM${product['product_price']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              addToCart(product);
              Navigator.pop(context);
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            query = value.toLowerCase();
            filteredProducts = products
                .where((product) =>
                    product['product_name'].toLowerCase().contains(query) ||
                    product['product_description']
                        .toLowerCase()
                        .contains(query))
                .toList();
          });
        },
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map product) {
    return Card(
      child: InkWell(
        onTap: () => showProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  "${MyConfig.servername}/${product['product_image']}",
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product['product_name'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              Text("RM${product['product_price']}",
                  style: const TextStyle(color: Colors.green)),
              ElevatedButton(
                onPressed: () => addToCart(product),
                child: const Text("Add to Cart"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: currentPage > 1
                ? () {
                    setState(() => currentPage--);
                    loadProducts();
                  }
                : null,
            child: const Text("Previous"),
          ),
          Text("Page $currentPage of $totalPages"),
          ElevatedButton(
            onPressed: currentPage < totalPages
                ? () {
                    setState(() => currentPage++);
                    loadProducts();
                  }
                : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return Scaffold(
                  appBar: AppBar(title: const Text("Cart")),
                  body: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final product = cart[index];
                      return ListTile(
                        title: Text(product['product_name']),
                        subtitle: Text("RM${product['product_price']}"),
                      );
                    },
                  ),
                );
              }));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    )
                  : Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        children: List.generate(
                          filteredProducts.length,
                          (index) => _buildProductCard(filteredProducts[index]),
                        ),
                      ),
                    ),
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewProductScreen()),
          );
          loadProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
