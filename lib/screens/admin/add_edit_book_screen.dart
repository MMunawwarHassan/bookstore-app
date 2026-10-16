import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book_model.dart';
import '../../providers/admin_provider.dart';

class AddEditBookScreen extends ConsumerStatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  ConsumerState<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends ConsumerState<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.book?.title);
  late final _author = TextEditingController(text: widget.book?.author);
  late final _genre = TextEditingController(text: widget.book?.genre);
  late final _price =
      TextEditingController(text: widget.book?.price.toString());
  late final _cover = TextEditingController(text: widget.book?.coverUrl);
  late final _desc = TextEditingController(text: widget.book?.description);
  late bool _bestseller = widget.book?.isBestseller ?? false;
  bool _loading = false;

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'title': _title.text.trim(),
      'author': _author.text.trim(),
      'genre': _genre.text.trim(),
      'price': double.parse(_price.text.trim()),
      'coverUrl': _cover.text.trim(),
      'description': _desc.text.trim(),
      'isBestseller': _bestseller,
    };
    try {
      final svc = ref.read(adminServiceProvider);
      if (widget.book == null) {
        await svc.addBook(data);
      } else {
        await svc.updateBook(widget.book!.id, data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Book saved')));
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
    final editing = widget.book != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Book' : 'Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      controller: _title,
                      validator: _required,
                      decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 14),
                  TextFormField(
                      controller: _author,
                      validator: _required,
                      decoration: const InputDecoration(labelText: 'Author')),
                  const SizedBox(height: 14),
                  TextFormField(
                      controller: _genre,
                      validator: _required,
                      decoration: const InputDecoration(labelText: 'Genre')),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Enter valid price'
                        : null,
                    decoration: const InputDecoration(labelText: 'Price (\$)'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                      controller: _cover,
                      validator: _required,
                      decoration:
                          const InputDecoration(labelText: 'Cover image URL')),
                  const SizedBox(height: 14),
                  TextFormField(
                      controller: _desc,
                      maxLines: 4,
                      validator: _required,
                      decoration:
                          const InputDecoration(labelText: 'Description')),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bestseller'),
                    value: _bestseller,
                    onChanged: (v) => setState(() => _bestseller = v),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(editing ? 'Update Book' : 'Add Book'),
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