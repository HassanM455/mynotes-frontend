// Define an abstract class or interface for ImageLoader
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


class ImageLoader {
  
  final ImgLdrImp _imgLdrImp = ImgLdrImp.factory() ; 

  Future<void> selectImages() async {
      await _imgLdrImp.selectImagesImp(); 
  }

  Future<void> loadImages() async {
      await _imgLdrImp.loadImagesImp() ; 
  }

  Future<List<Image>> getImages() => _getImages() ; 

  Future<List<Image>> _getImages() async {

    if (_imgLdrImp.imagesLoaded == false) {
      await loadImages() ; 
    }
    List<Image> images =  await _imgLdrImp.getImagesImp() ; 

    return images ; 
  }

  void clearImages() {
    _imgLdrImp.clearImagesImp() ;
  }

}

abstract class ImgLdrImp {

  Future<void> selectImagesImp();
  Future<void> loadImagesImp();
  
  Future<List<Image>> getImagesImp() ;

  bool get imagesLoaded ; 

  void clearImagesImp() ;
 
  factory ImgLdrImp.factory() {
    switch (Platform.operatingSystem) {
      case 'macos':
        return MacOSImgLdrImp();
      case 'ios':
        return IOSImgLdrImp();
      default:
        throw UnsupportedError('Operating system not supported: ${Platform.operatingSystem}');
    }  
  }
}

mixin ImgLdrImpMixin {

  Future<void> _handleEmptySelectedFiles(ImgLdrImp imgLdrImp) async {
      await imgLdrImp.selectImagesImp() ;   
  }

}

class IOSImgLdrImp with ImgLdrImpMixin implements ImgLdrImp  {

  final ImagePicker _imagePicker = ImagePicker() ;
  List<XFile> _selectedFiles = [] ;
  List<Image> _loadedImages = [] ; 

  @override
  Future<List<Image>> getImagesImp() => Future.value(_loadedImages) ; 
  
  @override
  bool get imagesLoaded => _loadedImages.isNotEmpty ; 

  @override
  Future<void> selectImagesImp() async {
    _selectedFiles = await _imagePicker.pickMultiImage() ; 
  }

  @override
  void clearImagesImp() {
    _selectedFiles.clear() ; 
    _loadedImages.clear() ;     
  }

  @override
  Future<void> loadImagesImp() async {

    if (_selectedFiles.isEmpty) {
      await _handleEmptySelectedFiles(this) ; 
    }

    _loadedImages = _selectedFiles.map(
      (xFile) => Image.file(
        File(xFile.path)
      )
    ).toList() ; 
  }
}



class MacOSImgLdrImp with ImgLdrImpMixin implements ImgLdrImp {


  List<XFile> _selectedFiles = [] ;
  List<Image> _loadedImages = [] ;

  FilePicker _filePicker = FilePicker.platform ; 

  @override
  Future<void> selectImagesImp() async {
    FilePickerResult? _filePickerResult = await _filePicker.pickFiles(
      allowMultiple: true,
    ) ;

    if (_filePickerResult != null && _filePickerResult.paths.isNotEmpty) {
      _selectedFiles = _filePickerResult.paths.where((path) => path != null).map(
        (path) => XFile(path!)
      ).toList();
    } else {
      _selectedFiles = [];
    }
  }

  @override
  Future<void> loadImagesImp() async {
    if (_selectedFiles.isEmpty) {
      await _handleEmptySelectedFiles(this) ; 
    }

    _loadedImages = _selectedFiles.map(
      (xFile) => Image.file(
        File(xFile.path)
      )
    ).toList() ; 
  }
  
  @override
  Future<List<Image>> getImagesImp() => Future.value(_loadedImages) ; 

  @override
  bool get imagesLoaded => _loadedImages.isNotEmpty ; 

  @override
  void clearImagesImp() {
    _selectedFiles.clear() ; 
    _loadedImages.clear() ;     
  }


}


