import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../repository/model/profile.dart';
import 'package:image_cropper/image_cropper.dart';

import '../utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    Key? key,
    required EditProfileBloc editProfileBloc,
  })  : _editProfileBloc = editProfileBloc,
        super(key: key);

  final EditProfileBloc _editProfileBloc;

  @override
  EditProfileScreenState createState() {
    return EditProfileScreenState(_editProfileBloc);
  }
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileBloc _editProfileBloc;
  EditProfileScreenState(this._editProfileBloc);
  final TextStyle titleTextStyle = TextStyle(
    color: Color(0xFFAAAAAA),
    fontSize: 20.0,
  );
  TextEditingController? _textEditingController1;
  TextEditingController? _textEditingController2;
  TextEditingController? _textEditingController3;
  TextEditingController? _textEditingController4;
  TextEditingController? _textEditingController5;
  File? profilePic;
  Profile? userProfile;
  File? image;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this._load();
    _textEditingController1 = TextEditingController();
    _textEditingController2 = TextEditingController();
    _textEditingController3 = TextEditingController();
    _textEditingController4 = TextEditingController();
    _textEditingController5 = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateProfile() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text('Some of your information is not valid'),
        ),
      );

      return;
    }

    String? bio = (_textEditingController1!.text != null &&
            _textEditingController1!.text.length > 3)
        ? _textEditingController1!.text
        : null;

    String? favoriteFood = (_textEditingController2!.text != null &&
            _textEditingController2!.text.length > 3)
        ? _textEditingController2!.text
        : null;

    String? cantEatFood = (_textEditingController3!.text != null &&
            _textEditingController3!.text.length > 3)
        ? _textEditingController3!.text
        : null;

    String? language = (_textEditingController4!.text != null &&
            _textEditingController4!.text.length > 3)
        ? _textEditingController4!.text
        : null;

    String? location = (_textEditingController5!.text != null &&
            _textEditingController5!.text.length > 3)
        ? _textEditingController5!.text
        : null;

    userProfile = Profile(
      bio: bio,
      favoriteFood: favoriteFood,
      cantEatFood: cantEatFood,
      name: userProfile!.name,
      picture: userProfile!.picture,
      location: location,
      languages: [language],
    );

    widget._editProfileBloc
        .add(UploadProfileEvent(userProfile, imageFile: image));
  }

  Future<bool> _onWillPop() {
    // if (!_pc.isPanelClosed()) {
    //   _pc.close();
    //   return Future.value(false);
    // }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      bloc: widget._editProfileBloc,
      builder: (
        BuildContext context,
        EditProfileState currentState,
      ) =>
          BaseBloc.widgetBlocBuilderDecorator(
        context,
        currentState,
        builder: (
          BuildContext context,
          EditProfileState currentState,
        ) {
          if (currentState is ErrorEditProfileState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ackAlert(context, currentState.errorMessage);
              widget._editProfileBloc.add(LoadEditProfileEvent(false));
            });
          }

          if (currentState is InEditProfileState &&
              currentState.hasUpdatedProfile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: Colors.blue.shade500,
                    content: Text('Your profile has been updated'),
                    onVisible: () {
                      widget._editProfileBloc.add(UnEditProfileEvent());
                      Navigator.of(context).pop(currentState);
                    }),
              );
            });
          }

          List<Widget> list = [
            _buildBody(context, currentState),
          ];

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: list,
            ),
          );
        },
      ),
    );
  }

  _buildProfilePic(BuildContext context, Profile? profile) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1), // border color
                shape: BoxShape.circle,
              ),
              child: (profile == null ||
                      (profile.picture?.url?.length ?? 0) <= 1)
                  ? SvgPicture.asset('assets/images/default-profile-pic.svg')
                  : CircleAvatar(
                      radius: 16,
                      backgroundImage: ((image == null)
                          ? NetworkImage(
                              profile.picture!.url!,
                            )
                          : FileImage(image!)) as ImageProvider<Object>?,
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () {
                  showAlertDialog3(context,
                      title: 'Select photo source',
                      message: '',
                      text1: 'Cancel',
                      text2: 'Camera',
                      text3: 'Album', onPressed: (String text) {
                    if (text == 'Camera') {
                      _getImageFromCamera().then((_) => _cropImage());
                    }
                    if (text == 'Album') {
                      _getImageFromGallery().then((_) => _cropImage());
                    }
                    Navigator.of(context).pop();
                  });
                },
                child: Text('Change profile picture',
                    softWrap: false,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.button),
              ),
            )
          ],
        ));
  }

  Future _getImageFromGallery() async {
    var pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  Future _getImageFromCamera() async {
    var pickedImage = await ImagePicker().getImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  Future<void> _cropImage() async {
    CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: image!.path,
        cropStyle: CropStyle.rectangle,
        aspectRatio: CropAspectRatio(ratioX: 800, ratioY: 800));

    setState(() {
      image = cropped as File? ?? image;
    });
  }

  Widget _buildFormFields() {
    return SizedBox(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Personal bio',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 50,
                maxLines: 1,
                controller: _textEditingController1,
                decoration: InputDecoration(
                  hintText: 'Add a few words about yourself',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.length <= 3) {
                    return 'Please enter more text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Languages',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 50,
                maxLines: 1,
                controller: _textEditingController4,
                decoration: InputDecoration(
                  hintText: 'Let people know what languages you speak',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter at least one language';
                  }
                  if (value.length <= 3) {
                    return 'Please enter at least one language';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Location',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 50,
                maxLines: 1,
                controller: _textEditingController5,
                decoration: InputDecoration(
                  hintText: 'Let people know where you live',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter at least one location';
                  }
                  if (value.length <= 3) {
                    return 'Please enter at least one location';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Foods you love',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 50,
                maxLines: 1,
                controller: _textEditingController2,
                decoration: InputDecoration(
                  hintText: 'Let people know what kind of food you love',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.length <= 3) {
                    return 'Please enter more text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Foods you hate',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 50,
                maxLines: 1,
                controller: _textEditingController3,
                decoration: InputDecoration(
                  hintText: 'Things you won\'t or can\'t eat? Add them here',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.length <= 3) {
                    return 'Please enter more text';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3345A9), shape: StadiumBorder()),
                onPressed: updateProfile,
                child: Text(
                  "Update Profile",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBody(
    BuildContext context,
    EditProfileState currentState,
  ) {
    if (currentState is InEditProfileState) {
      userProfile = currentState.profile;
      _textEditingController1!.text = userProfile!.bio!;
      _textEditingController2!.text = userProfile!.favoriteFood!;
      _textEditingController3!.text = userProfile!.cantEatFood!;
      _textEditingController4!.text = userProfile!.languages?.join(', ') ?? '';
      _textEditingController5!.text = userProfile!.location!;
    }
    return CustomScrollView(
        // controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(16),
                child: Column(children: <Widget>[
                  _buildProfilePic(context, userProfile),
                  _buildFormFields(),
                  // GestureDetector(onTap: () {}, child: _builDeleteAccount()),
                ]),
              ),
            ]),
          )
        ]);
  }

  void _load([bool isError = false]) {
    widget._editProfileBloc.add(UnEditProfileEvent());
    widget._editProfileBloc.add(LoadEditProfileEvent(isError));
  }
}
