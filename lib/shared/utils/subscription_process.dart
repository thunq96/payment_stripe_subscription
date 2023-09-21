import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_app/shared/utils/api_service.dart';

import '../../main.dart';

// +++++++++++++++++++++++++++++++++++
// ++ STRIPE PAYMENT INITIALIZATION ++
// +++++++++++++++++++++++++++++++++++

initPayment()  {
  print("mkldsmflksdmfldsmfklds111111111");
  Stripe.publishableKey = STRIPE_PUBLISHABLE_KEY;
  print("mkldsmflksdmfldsmfklds");
}

Future<bool> getStatusSubscription({String customerId = 'cus_OfhAsLpG3T5YhC',
  String priceId = 'price_1Ns0zrCnpXbCFE1yo4vEmBNp'}) async {
  final listSub = await apiService(
    endpoint: 'subscriptions?status=active&customer=$customerId&price=$priceId',
    requestMethod: ApiServiceMethodType.get,
  );
  for (int i = 0; i < (listSub!['data']?.length ?? 0); i++) {
    if (listSub['data'][i]['status'] == 'active') {
      return true;
    }
  }
  return false;
}

Future<String> getListPrice() async {
  final listProduct = await apiService(
      endpoint: 'prices?active=true', requestMethod: ApiServiceMethodType.get);
  if (listProduct?.isNotEmpty == true &&
      (listProduct!['data'] as List).isNotEmpty) {
    print("listProduct!['data'] = ${listProduct['data'][0]['id']}");
    return listProduct['data'][0]['id'];
  }
  return '';
}

Future<void> createPayment({String titleAction = 'Subscribe \$10.00',
  String merchantName = 'Flutter Stripe Store Demo',
  String nickName = 'Gabriel Parada',
  String email = 'thutest11@demo.com',
  String description = 'Flutter created',
  String price = 'price_1Ns0zrCnpXbCFE1yo4vEmBNp',
  String trialDay = "30",
  Function? callBack}) async {
  Map<String, dynamic> customer = await createCustomer(
      email: email, nickName: nickName, description: description);
  Map<String, dynamic> paymentIntent = await createPaymentIntent(
    customer['id'],
  );
  await createCreditCard(
      merchantName: merchantName,
      title: titleAction,
      customerId: customer['id'],
      paymentIntentClientSecret: paymentIntent['client_secret']);
  Map<String, dynamic> customerPaymentMethods =
  await getCustomerPaymentMethods(customerId: customer['id']);
  await updateCustomer(
      customerId: customer['id'],
      paymentId: customerPaymentMethods['data'][0]['id']);

  Map<String, dynamic> sub = await createSubscription(
    price: price,
    trialDay: trialDay,
    customerId: customer['id'],
    paymentId: customerPaymentMethods['data'][0]['id'],
  );
  print("subsubsubsubsubsub = $sub");
  callBack?.call(customer['id'], sub["id"]);
}

Future<void> updatePayment({String customerId = '',
  String titleAction = 'Subscribe \$10.00',
  String merchantName = 'Flutter Stripe Store Demo',
  String price = 'price_1Ns0zrCnpXbCFE1yo4vEmBNp',
  String trialDay = "30",
  String subscriptionId = "",
  Function? callBack}) async {
  Map<String, dynamic> paymentIntent = await createPaymentIntent(
    customerId,
  );
  await cancelSubscription(subscriptionId);
  await createCreditCard(
      merchantName: merchantName,
      title: titleAction,
      customerId: customerId,
      paymentIntentClientSecret: paymentIntent['client_secret']);
  Map<String, dynamic> customerPaymentMethods =
  await getCustomerPaymentMethods(customerId: customerId);
  await updateCustomer(
      customerId: customerId,
      paymentId: customerPaymentMethods['data'][0]['id']);
  print("customerPaymentMethods = $customerPaymentMethods");
  Map<String, dynamic> sub = await createSubscription(
    price: price,
    trialDay: trialDay,
    customerId: customerId,
    paymentId: customerPaymentMethods['data'][0]['id'],
  );
  callBack?.call(sub["id"]);
}
// +++++++++++++++++++++
// ++ CREATE CUSTOMER ++
// +++++++++++++++++++++

Future<Map<String, dynamic>> createCustomer(
    {String nickName = '', String email = '', String description = ''}) async {
  final customerCreationResponse = await apiService(
    endpoint: 'customers',
    requestMethod: ApiServiceMethodType.post,
    requestBody: {
      'name': nickName,
      'email': email,
      'description': description,
    },
  );

  return customerCreationResponse!;
}

Future<Map<String, dynamic>> updateCustomer(
    {String customerId = '', String paymentId = ''}) async {
  final customerCreationResponse = await apiService(
    endpoint: 'customers/$customerId',
    requestMethod: ApiServiceMethodType.post,
    requestBody: {
      'invoice_settings[default_payment_method]': paymentId,
    },
  );

  return customerCreationResponse!;
}
// ++++++++++++++++++++++++++
// ++ SETUP PAYMENT INTENT ++
// ++++++++++++++++++++++++++

Future<Map<String, dynamic>> createPaymentIntent(String customerId) async {
  final paymentIntentCreationResponse = await apiService(
    requestMethod: ApiServiceMethodType.post,
    endpoint: 'setup_intents',
    requestBody: {
      'customer': customerId,
      'automatic_payment_methods[enabled]': 'true',
    },
  );

  return paymentIntentCreationResponse!;
}

// ++++++++++++++++++++++++
// ++ CREATE CREDIT CARD ++
// ++++++++++++++++++++++++

Future<void> createCreditCard({
  String title = '',
  String merchantName = '',
  String customerId = '',
  String paymentIntentClientSecret = '',
}) async {
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      primaryButtonLabel: title,
      style: ThemeMode.light,
      merchantDisplayName: merchantName,
      customerId: customerId,
      setupIntentClientSecret: paymentIntentClientSecret,
    ),
  );

  await Stripe.instance.presentPaymentSheet();
}

// +++++++++++++++++++++++++++++++++
// ++ GET CUSTOMER PAYMENT METHOD ++
// +++++++++++++++++++++++++++++++++

Future<Map<String, dynamic>> getCustomerPaymentMethods({
  String customerId = '',
}) async {
  final customerPaymentMethodsResponse = await apiService(
    endpoint: 'customers/$customerId/payment_methods',
    requestMethod: ApiServiceMethodType.get,
  );

  return customerPaymentMethodsResponse!;
}

// +++++++++++++++++++++++++
// ++ CREATE SUBSCRIPTION ++
// +++++++++++++++++++++++++

Future<Map<String, dynamic>> createSubscription({String customerId = '',
  String paymentId = '',
  String price = '',
  String trialDay = ""}) async {
  final subscriptionCreationResponse = await apiService(
    endpoint: 'subscriptions',
    requestMethod: ApiServiceMethodType.post,
    requestBody: {
      'customer': customerId,
      'items[0][price]': price,
      'default_payment_method': paymentId,
      'trial_period_days': trialDay,
    },
  );

  return subscriptionCreationResponse!;
}

Future<Map<String, dynamic>> cancelSubscription(String subscriptionId,) async {
  final subscriptionCreationResponse = await apiService(
    endpoint: 'subscriptions/$subscriptionId',
    requestMethod: ApiServiceMethodType.delete,
  );

  return subscriptionCreationResponse!;
}
