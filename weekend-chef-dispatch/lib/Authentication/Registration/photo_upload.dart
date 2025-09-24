import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weekend_chef_dispatch/Authentication/Registration/password.dart';
import 'package:weekend_chef_dispatch/Components/photos/select_photo_options_screen.dart';
import 'package:weekend_chef_dispatch/constants.dart';

class UploadPhotoReg extends StatefulWidget {
  final data;

  const UploadPhotoReg({
    super.key,
    required this.data,
  });

  @override
  State<UploadPhotoReg> createState() => _UploadPhotoRegState();
}

class _UploadPhotoRegState extends State<UploadPhotoReg> {
  FocusNode focusNode = FocusNode();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      // color: bookWhite,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Account Setup',
                                style: TextStyle(fontSize: 25),
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Add your profile picture stand out.',
                                style: TextStyle(fontSize: 12),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          //key: _formKey,
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.1))),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _showSelectPhotoOptions(context);
                                            },
                                            child: _image == null
                                                ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          size: 50,
                                                          color: Colors.black,
                                                        ),
                                                        SizedBox(height: 20),
                                                        Text(
                                                          "Upload photo",
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 20),
                                                        /*   Text(
                                                "(Optional)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.grey),
                                              ),*/
                                                      ],
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundImage:
                                                        FileImage(_image!),
                                                    radius: 200.0,
                                                  ),
                                          ),
                                          if (_image != null)
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _image = null;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.white,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(8),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      if (_image != null) ...[
                        InkWell(
                          onTap: () {
                            widget.data['photo'] = _image!.path;

                            print("#######");
                            //print(widget.data.toString());

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Password(data: widget.data)));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(15),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: bookPrimary,
                                borderRadius: BorderRadius.circular(7)),
                            child: Center(
                              child: Text(
                                "Next",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Password(data: widget.data)));
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              //   color: bookPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7)),
                          child: Center(
                            child: Text(
                              "Skip",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }
}
