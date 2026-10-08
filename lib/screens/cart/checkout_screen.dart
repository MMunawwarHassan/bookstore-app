import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _phone = TextEditingController();

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(cartProvider.notifier).clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Order Placed!'),
        content: const Text('Thank you. Payment: Cash on Delivery.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Order Summary',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  for (final c in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('${c.book.title} x ${c.quantity}',
                                  overflow: TextOverflow.ellipsis)),
                          Text('\$${c.total.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Shipping Details',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().length < 8)
                        ? 'Enter full address'
                        : null,
                    decoration: const InputDecoration(
                        labelText: 'Shipping address',
                        prefixIcon: Icon(Icons.location_on_outlined)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Enter valid phone number'
                        : null,
                    decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_outlined)),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.payments_outlined),
                    title: Text('Cash on Delivery'),
                    subtitle: Text('Pay when the order arrives'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: items.isEmpty ? null : _placeOrder,
                    child: const Text('Place Order'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}