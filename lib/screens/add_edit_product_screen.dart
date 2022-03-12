import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({Key? key}) : super(key: key);

  static const routeName = '/add-edit-product-screen';

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  var _isInit = true;
  var _isLoading = false;
  var _title;
  final _form = GlobalKey<FormState>();
  var _imageURLController = TextEditingController();
  var _imageUrlFocusNode = FocusNode();
  late ProductProvider _productProvider;
  var _tempProduct = MyProduct(
    id: DateTime.now().toString(),
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _productProvider = Provider.of<ProductProvider>(context, listen: false);
      _title = ModalRoute.of(context)?.settings.arguments;
      if (_title != null) {
        _tempProduct = _productProvider.findById(_title);
        _imageURLController.text = _tempProduct.imageUrl;
      }

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _saveData() async {
    setState(() {
      _isLoading = true;
    });
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
      if (_productProvider.doesProductExit(_tempProduct.id)) {
        await _productProvider.updateProduct(_tempProduct.id, _tempProduct);
        setState(() {
          _isLoading = false;
          Navigator.of(context).pop();
        });
      } else {
        try {
          await _productProvider.addProduct(_tempProduct);
        } catch (e) {
          await showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text('An error occurred!'),
                content:
                    const Text('Shomething went wrong. Please try again...'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay'),
                  )
                ],
              );
            },
          );
        } finally {
          setState(() {
            _isLoading = false;
            Navigator.of(context).pop();
          });
        }
      }
    }
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 100;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            onPressed: () => _saveData(),
            icon: const Icon(Icons.save_outlined),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      Container(
                        height: width * 2 / 3,
                        width: width,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageURLController.text.isEmpty
                            ? const Center(
                                child: Text(
                                  'Inset an image URL. Preferrd Ratio 3:2',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Image.network(
                                _imageURLController.text,
                                fit: BoxFit.cover,
                              ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        initialValue: _tempProduct.title,
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _tempProduct = MyProduct(
                              id: _tempProduct.id,
                              title: value!,
                              description: _tempProduct.description,
                              price: _tempProduct.price,
                              imageUrl: _tempProduct.imageUrl,
                              isFavorite: _tempProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a title.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'description'),
                        initialValue: _tempProduct.description,
                        keyboardType: TextInputType.multiline,
                        maxLength: 250,
                        maxLines: 5,
                        minLines: 1,
                        onSaved: (value) {
                          _tempProduct = MyProduct(
                              id: _tempProduct.id,
                              title: _tempProduct.title,
                              description: value!,
                              price: _tempProduct.price,
                              imageUrl: _tempProduct.imageUrl,
                              isFavorite: _tempProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a description.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Price'),
                        initialValue: _tempProduct.price == 0
                            ? ''
                            : _tempProduct.price.toString(),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _tempProduct = MyProduct(
                              id: _tempProduct.id,
                              title: _tempProduct.title,
                              description: _tempProduct.description,
                              price: int.parse(value!),
                              imageUrl: _tempProduct.imageUrl,
                              isFavorite: _tempProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Price can\'t be empty.';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid price';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Price couldn\'t be zero or less.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        controller: _imageURLController,
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.url,
                        focusNode: _imageUrlFocusNode,
                        onSaved: (value) {
                          _tempProduct = MyProduct(
                              id: _tempProduct.id,
                              title: _tempProduct.title,
                              description: _tempProduct.description,
                              price: _tempProduct.price,
                              imageUrl: value!,
                              isFavorite: _tempProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide an image Url.';
                          } else {
                            return null;
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
