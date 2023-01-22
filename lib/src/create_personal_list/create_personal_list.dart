import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rice/src/base_bloc.dart';
import 'package:rice/src/create_personal_list/create_personal_list_bloc.dart';
import 'package:rice/src/create_personal_list/create_personal_list_event.dart';
import 'package:rice/src/create_personal_list/create_personal_list_state.dart';
import 'package:rice/src/repository/model/profile.dart' as model;
import 'package:rice/src/repository/rice_repository.dart';

typedef void OnCompleteCallback(bool shouldRefresh);

class CreatePersonalList extends StatelessWidget {
  final OnCompleteCallback onComplete;

  CreatePersonalList({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final bloc =
        CreatePersonalListBloc(riceRepository: context.read<RiceRepository>());

    return CreatePersonalListForm(
      bloc: bloc,
      onComplete: this.onComplete,
    );
  }
}

class CreatePersonalListForm extends StatefulWidget {
  final CreatePersonalListBloc bloc;
  final OnCompleteCallback onComplete;

  CreatePersonalListForm({required this.bloc, required this.onComplete});

  @override
  _CreatePersonalListFormState createState() => _CreatePersonalListFormState();
}

class _CreatePersonalListFormState extends State<CreatePersonalListForm> {
  final _textEditingController1 = TextEditingController(text: '');

  File? image;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: this.widget.bloc,
      builder: (BuildContext context, CreatePersonalListState state) {
        return BaseBloc.widgetBlocBuilderDecorator(
          context,
          state,
          builder: (context, dynamic state) {
            if (state is SavedPersonalListState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                this.widget.bloc.add(InCreatePersonalListEvent());

                this.widget.onComplete(true);
              });
            }

            final hasImage = this.image != null;

            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Color(0xFFD8D8D8),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'List name',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    maxLines: 1,
                    controller: _textEditingController1,
                    decoration: InputDecoration(
                      hintText: 'A cool name for your list',
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
                  SizedBox(height: 24),
                  Text(
                    'Cover photo (Optional)',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      this.setState(() {
                        if (image != null) {
                          this.image = File(image.path);
                        }
                      });
                    },
                    child: Container(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Icon(
                          Icons.photo_camera,
                          color: !hasImage ? Color(0xFF3345A9) : Colors.white,
                        ),
                        decoration: BoxDecoration(
                          color:
                              !hasImage ? null : Colors.black.withOpacity(.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(8),
                        image: !hasImage
                            ? null
                            : DecorationImage(
                                image: FileImage(this.image!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  ButtonTheme(
                    minWidth: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3345A9),
                          shape: StadiumBorder()),
                      child: Text(
                        "Create List",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: state is SavingPersonalListState
                          ? null
                          : _savePersonalList,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _savePersonalList() {
    this.widget.bloc.add(SavingPersonalListEvent());

    final event = SavePersonalListEvent(
      personalList: model.CreatePersonalList(
        name: _textEditingController1.text,
        cover: this.image,
      ),
    );

    this.widget.bloc.add(event);
  }
}
