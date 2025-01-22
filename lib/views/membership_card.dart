import 'package:flutter/material.dart';
import 'package:my_member_link/models/membership.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http; // For making HTTP requests

class MembershipCard extends StatefulWidget {
  final Membership membership;
  final Function(Membership) onAddToCart;

  MembershipCard({required this.membership, required this.onAddToCart});

  @override
  _MembershipCardState createState() => _MembershipCardState();
}

class _MembershipCardState extends State<MembershipCard> {
  void _createPaymentEntryAndNavigate(double amount) async {
    final String userId = "4"; // Replace with actual user ID
    final String purchaseDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final String paymentStatus = "Pending";
    final String membershipName = widget.membership.membershipName ??
        'No Name'; // Get the membership name

    // API URL to save payment entry
    final String apiUrl =
        "${MyConfig.servername}/memberlink/api/create_payment.php";

    try {
      // Make POST request to the API
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "user_id": userId,
          "membership_name": membershipName, // Send the membership name
          "purchase_date": purchaseDate,
          "payment_amount": amount.toString(),
          "payment_status": paymentStatus,
        },
      );

      // Debugging: Log response status and body
      print("Response status: ${response.statusCode}\n");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Payment entry created successfully.");
      } else {
        print("Failed to create payment entry: ${response.body}");
        // Show a Snackbar to the user indicating failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create payment entry."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Catch and log any error during the HTTP request
      print("Error creating payment entry: $e");

      // Show a Snackbar to the user indicating error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Debugging: Log that we're about to navigate
    print("Navigating to the payment screen");

    // Navigate to the payment screen, passing the user_id and amount
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(amount: amount, userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      elevation: 4.0,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[850],
              title: Text(widget.membership.membershipName ?? 'No Name',
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.membership.membershipPicture != null)
                    Image.asset(widget.membership.membershipPicture!,
                        height: 100)
                  else
                    const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.white),
                  const SizedBox(height: 10),
                  Text('Price: RM${widget.membership.membershipPrice ?? 'N/A'}',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                      widget.membership.membershipDescription ??
                          'No Description Available',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              actions: [
                // Purchase Now Button
                TextButton(
                  onPressed: () {
                    final double price = double.tryParse(
                            widget.membership.membershipPrice.toString()) ??
                        0.0;

                    // Call the method to create a payment entry and navigate to the payment screen
                    _createPaymentEntryAndNavigate(price);

                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Purchase Now',
                      style: TextStyle(color: Colors.white)),
                ),
                // Close Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: widget.membership.membershipPicture != null
                  ? Image.asset(
                      widget.membership.membershipPicture!,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child:
                          Icon(Icons.image_not_supported, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.membership.membershipName ?? 'No Name',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\RM${widget.membership.membershipPrice ?? 'N/A'}',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  final double amount;
  final String userId; // Add userId as a parameter

  PaymentScreen({required this.amount, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Update the payment URL to include user_id as a query parameter
    final String paymentUrl =
        '${MyConfig.servername}/memberlink/api/payment.php?amount=$amount&user_id=$userId';

    // Debugging: Log the URL that is being loaded
    print("Loading payment URL: $paymentUrl");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.grey[900],
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(paymentUrl)),
      ),
    );
  }
}
