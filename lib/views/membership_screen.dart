import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_member_link/models/membership.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/mydrawer.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/views/membership_card.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  late double screenWidth, screenHeight;
  String status = "Loading...";

  Future<List<Membership>> loadMembershipData() async {
    try {
      final response = await http.get(Uri.parse(
          "${MyConfig.servername}/memberlink/api/load_membership.php"));
      // Log the raw response body to see what the server returned
      log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['memberships'];
          List<Membership> membershipList = [];
          if (result.isEmpty) {
            // Show SnackBar when no memberships are available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No data available'),
                backgroundColor: Colors.red, // Red background for error
                duration: Duration(seconds: 2), // Duration for the SnackBar
              ),
            );
          } else {
            for (var item in result) {
              Membership myMembership = Membership.fromJson(item);
              membershipList.add(myMembership);
            }
          }
          return membershipList;
        } else if (data['status'] == "empty") {
          throw Exception('No memberships found.');
        } else {
          throw Exception('No Data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for the screen
      appBar: AppBar(
        title: const Text('Membership Screen',
            style: TextStyle(color: Colors.white)), // Set text color to white
        backgroundColor: Colors.black, // Dark app bar
        elevation: 0,
      ),
      body: FutureBuilder<List<Membership>>(
        future: loadMembershipData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            // Display memberships if the data is successfully loaded
            var membershipList = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: membershipList.length,
              itemBuilder: (context, index) {
                return MembershipCard(
                  membership: membershipList[index],
                  onAddToCart: (Membership membership) {
                    // Logic for add to cart (if any)
                  },
                );
              },
            );
          }
        },
      ),
      drawer: const MyDrawer(),
    );
  }
}
