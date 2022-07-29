import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:filterr/widget/filtered_image_list_widget.dart';
import 'package:filterr/widget/filtered_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';

import 'filter_utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  img.Image? image;
  Uint8List? imageBytes;
  Filter filter = presetFiltersList.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("فلاتر جميلة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () => getImage(ImageSource.gallery),
          ),
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => getImage(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                filter = presetFiltersList[3];
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          buildImage(),
          const SizedBox(height: 12),
          buildFilters(),
          ElevatedButton(
              onPressed: () async {
                //   var response = await Dio().get(
                //  "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg",
                //  options: Options(responseType: ResponseType.bytes));
                final result = await ImageGallerySaver.saveImage(
                    Uint8List.fromList(imageBytes!),
                    quality: 80);
                //print(result);
              },
              child: const Text("حفظ"))
        ],
      ),
    );
  }

  Future getImage(ImageSource sourceImage) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: sourceImage);
      imageBytes = File(image!.path).readAsBytesSync();

      final newImage = img.decodeImage(imageBytes!);
      FilterUtils.clearCache();

      setState(() {
        this.image = newImage!;
      });
    } catch (_) {}
  }

  Widget buildImage() {
    const double height = 450;
    if (image == null) return Container();

    return FilteredImageWidget(
      filter: filter,
      image: image!,
      successBuilder: (imageBytes) => Image.memory(
          Uint8List.fromList(imageBytes),
          height: height,
          fit: BoxFit.fitHeight),
      errorBuilder: () => Container(height: height),
      loadingBuilder: () => const SizedBox(
        height: height,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildFilters() {
    if (image == null) return Container();

    return FilteredImageListWidget(
      filters: presetFiltersList,
      image: image!,
      onChangedFilter: (filter) {
        setState(() {
          this.filter = filter;
        });
      },
    );
  }
}
