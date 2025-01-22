import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/views/mydrawer.dart';
import 'package:my_member_link/myconfig.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<Map<String, dynamic>> paymentList = [];
  late double screenWidth, screenHeight;
  bool isLoading = true; // To track loading state
  bool hasError = false; // To track if there's an error

  @override
  void initState() {
    super.initState();
    loadPaymentData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Payment List"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : paymentList.isEmpty
              ? Center(
                  child: Text(
                    "No payment records found.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: paymentList.length,
                  itemBuilder: (context, index) {
                    final payment = paymentList[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          payment['membership_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Purchase Date: ${payment['purchase_date']}"),
                            Text("Amount: \RM${payment['payment_amount']}"),
                          ],
                        ),
                        trailing: Text(
                          payment['payment_status'],
                          style: TextStyle(
                            color: payment['payment_status'] == "Paid"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void loadPaymentData() async {
    final url =
        Uri.parse('${MyConfig.servername}/memberlink/api/load_payments.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            paymentList = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else if (data['status'] == 'empty') {
          setState(() {
            paymentList = [];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
          showErrorSnackbar("Failed to load payment data.");
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        showErrorSnackbar("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      showErrorSnackbar("Error fetching payment data: $e");
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
