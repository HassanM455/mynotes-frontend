import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';


import 'image_loader/image_loader.dart'; 



Future<void> main() async {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CupertinoColors.systemPurple),
        useMaterial3: true,
      ),
      home: MainScreen(title: "My Notes App")
    );
  }
}

class MainScreen extends StatefulWidget {

  late final String title ; 

  // Defining the constructor
  // Potentially pass a kay parameter
  MainScreen({Key? key, required String title})
    : super(key: key) {

    this.title = title  ;
  }

  @override
  _MainScreenState createState() => _MainScreenState();

}



class _MainScreenState extends State<MainScreen> {
 
  ImageLoader imgLdr = ImageLoader() ;  

  late List<Widget> _items ; 
  late bool _imagesUnloaded ; 

  @override
  void initState() {
     super.initState();
    _imagesUnloaded = true ; 
  }

  Future<void> _addImages() async {

    imgLdr.clearImages(); 
    List<Image> images = await imgLdr.getImages() ; 
    setState(() {
      _items  = images.map((image) => Container(child: image)).toList() ; 
       
    });
  }

  Future<void> _clearImages(BuildContext context) async {
    imgLdr.clearImages();
  }


  void _addOrRemoveImages() async {
      
    _imagesUnloaded ? await _addImages() : await _clearImages(context) ;
    setState(
      () { _imagesUnloaded = !_imagesUnloaded ;}
    );
  } 


  @override
  Widget build(BuildContext context) {
    

    Widget _defaultText = Text(
        "Select Photos", 
        style: Theme.of(context).textTheme.headlineMedium,
    );

    if (_imagesUnloaded) {
      
      _items = [Center(child: _defaultText )] ;  
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(20),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex-- ;

            final item = _items.removeAt(oldIndex) ; 
            _items.insert(newIndex, item) ; 

          });
        }, 
        children: [
          for (int index = 0; index < _items.length; index++ ) 
            Container(
              padding: const EdgeInsets.all(50),
              key: Key('${index}'), 
              child: _items[index]
            )

        ] 
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrRemoveImages,
        tooltip: _imagesUnloaded ? 'Add Images' : 'Clear Images',
        child: _imagesUnloaded ? Icon(CupertinoIcons.add) : Icon(CupertinoIcons.clear)
      ),
    );
  }
}

