import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-screen';

  // const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var editedProduct = Product(
    id: '', 
    title: '', 
    description: '', 
    price: 0, 
    imageUrl: ''
  );
  var _initValues = {
    'title' : '', 
    'description' : '', 
    'price' : '', 
    'imageUrl' : ''};
  var isInit = true;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageURL);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(isInit){
      final productId = ModalRoute.of(context)?.settings.arguments as String;
      if (productId != 'newProduct'){
        editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title' : editedProduct.title, 
          'description' : editedProduct.description, 
          'price' : editedProduct.price.toString(), 
          'imageUrl' : '',
        };
        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose(){
    _imageUrlFocusNode.removeListener(_updateImageURL);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateImageURL(){
    if(!_imageUrlFocusNode.hasFocus){
      if ((!_imageUrlController.text.startsWith('http') 
            && !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('png') 
            && !_imageUrlController.text.endsWith('jpg') 
            && !_imageUrlController.text.endsWith('jpeg')
          )
        )
        {
          return ;
        }
      setState(() {});
    }
  }

  void _saveForm(){
    final isValid = _form.currentState?.validate();
    if (!isValid!){
      return ;
    }
    _form.currentState?.save();
    if(editedProduct.id != ''){
      Provider.of<Products>(context,listen: false)
        .updateProduct(editedProduct.id, editedProduct);
    }else{
      Provider.of<Products>(context,listen: false).addProduct(editedProduct);
    }
    Navigator.of(context).pop();
    // print(editedProduct.title);
    // print(editedProduct.description);
    // print(editedProduct.price);
    // print(editedProduct.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm, 
            icon: const Icon(Icons.save)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onSaved: ((Value) {
                  editedProduct = Product(
                    id: editedProduct.id,
                    isFavorite: editedProduct.isFavorite, 
                    title: Value ?? '', 
                    description: editedProduct.description, 
                    price: editedProduct.price, 
                    imageUrl: editedProduct.imageUrl,
                  );
                }),
                validator: (value) {
                  if(value!.isEmpty){
                    return 'Please provide a value';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: const InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onSaved: ((Value) {
                  editedProduct = Product(
                    id: editedProduct.id,
                    isFavorite: editedProduct.isFavorite, 
                    title: editedProduct.title, 
                    description: editedProduct.description, 
                    price: double.parse(Value ?? ''), 
                    imageUrl: editedProduct.imageUrl,
                  );
                }),
                validator: (value) {
                  if(value!.isEmpty){
                    return 'Please provide price value';
                  }
                  if(double.tryParse(value) == null){
                    return 'Please enter a valid number';
                  }
                  if(double.tryParse(value)! < 0){
                    return 'Please provide valid price';
                  }
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                onSaved: ((Value) {
                  editedProduct = Product(
                    id: editedProduct.id, 
                    isFavorite: editedProduct.isFavorite,
                    title:editedProduct.title, 
                    description: Value ?? '', 
                    price: editedProduct.price, 
                    imageUrl: editedProduct.imageUrl,
                  );
                }),
                validator: (value) {
                  if(value!.isEmpty){
                    return 'Please provide description';
                  }
                  if (value.length <10){
                    return 'Should be atleast 10 characters long';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin:const EdgeInsets.only(top: 8,right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    child: _imageUrlController.text.isEmpty 
                    ? const Text('Enter a URL') 
                    : FittedBox(
                      child: Image.network(_imageUrlController.text,fit: BoxFit.cover,),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      // initialValue: _initValues['imageUrl'],
                      decoration:const InputDecoration(
                        label: Text('Image URL')
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onSaved: ((Value) {
                        editedProduct = Product(
                          id: editedProduct.id, 
                          isFavorite: editedProduct.isFavorite,
                          title: editedProduct.title, 
                          description: editedProduct.description, 
                          price: editedProduct.price, 
                          imageUrl: Value ?? '',
                          );
                        }),
                              onEditingComplete: () {
                        setState(() {});
                      },
                      onFieldSubmitted: (value) {
                        _saveForm();
                      },
                      validator: (value) {
                        if(value!.isEmpty){
                          return 'Please provide Image URL';
                        }
                        if (!value.startsWith('http') && !value.startsWith('https')){
                          return 'Please Enter a Valid URL';
                        }
                        if (!value.endsWith('png') && !value.endsWith('jpg') && !value.endsWith('jpg')){
                          return 'Please Enter a Valid URL';
                        }
                        return null;
                      },
                    ),
                  ),

                ],
              )
            ],
          )
        ),
      ),
    );
  }
}