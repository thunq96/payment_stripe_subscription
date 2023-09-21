import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_app/stripe_app.dart';

String STRIPE_PUBLISHABLE_KEY = "pk_test_51N66n6CnpXbCFE1yr1SOdxDNCmpLB5J3Y9DZAtqMOTHjkO8ADnhPDARfg4RkEzTrMJwKgBtYLXrvlE6f2wf9XiMm00QMzs5YE5";
String STRIPE_PRIVATE_KEY="sk_test_51N66n6CnpXbCFE1yxQD9DGoSKg6P77Lxl8haDircZM80FjAeL7cEaAxD9ghAfZJitpAfmQX7mK9Ffv4ID5tRCaNk00mAb99gq4";


void main() {
  Stripe.publishableKey = STRIPE_PUBLISHABLE_KEY;
  runApp(const StripeApp());
}
