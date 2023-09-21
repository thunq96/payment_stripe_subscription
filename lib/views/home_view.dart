import 'package:flutter/material.dart';

import '../shared/payment_button.dart';
import '../shared/utils/subscription_process.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    // TODO: implement initState
    getStatusSubscription();
    getListPrice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Stripe App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PaymentButton(
              buttonTitle: "Subscribe",
              onPressed: () => createPayment(),
            ),
            SizedBox(
              height: 20,
            ),
            PaymentButton(
              buttonTitle: "Cancel Subscribe",
              onPressed: () => createPayment(),
            ),
          ],
        ),
      ),
    );
  }
}
