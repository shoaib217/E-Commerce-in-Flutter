import 'package:flutter/material.dart';

class AddNewProduct extends StatefulWidget {
  const AddNewProduct({super.key});

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var selectedCategory = "";
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _productDetailController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final List<String> category = [
    "Select Category",
    "smartphone",
    "laptops",
    "fragrances",
    "skincare",
    "groceries",
    "home-decoration"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 12, right: 12),
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Brand Name',
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productDetailController,
                decoration: const InputDecoration(
                  hintText: 'Enter Product Details',
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product details';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'Price',
                ),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  hintText: 'Rate a Product Between 1 to 5',
                ),
                maxLength: 3,
                onChanged: (value) {
                  if (double.parse(_rateController.text.toString()) > 5 ||
                      double.parse(_rateController.text.toString()) == 0) {
                    _rateController.text = "";
                  }
                },
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Rating';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'Enter Product Image Url',
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Image url';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: DropdownMenu<String>(
                  initialSelection: category.first,
                  onSelected: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  dropdownMenuEntries:
                      category.map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                        value: value, label: value);
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: FilledButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (selectedCategory.isEmpty ||
                        selectedCategory == category.first) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select Category"),
                        ),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {}
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
