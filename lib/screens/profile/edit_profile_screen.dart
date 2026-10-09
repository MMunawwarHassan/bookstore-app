import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _payment = 'Cash on Delivery';
  bool _loading = false;

  static const _methods = [
    'Cash on Delivery',
    'Credit/Debit Card',
    'JazzCash / Easypaisa',
  ];

  @override
  void initState() {
    super.initState();
    final p = ref.read(userProfileProvider).value;
    final user = ref.read(authServiceProvider).currentUser;
    _name.text = p?['name'] ?? user?.displayName ?? '';
    _phone.text = p?['phone'] ?? '';
    _address.text = p?['address'] ?? '';
    _payment = p?['paymentMethod'] ?? 'Cash on Delivery';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(userServiceProvider).updateProfile(
            uid: user.uid,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            paymentMethod: _payment,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                  TextFormField(
                    controller: _name,
                    validator: Validators.name,
                    decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline)),
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
                  const SizedBox(height: 20),
                  Text('Payment method',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in _methods)
                        ChoiceChip(
                          label: Text(m),
                          selected: _payment == m,
                          onSelected: (_) => setState(() => _payment = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Changes'),
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