import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCheckBox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  void _actionHandler(){
    if (onChanged != null) {
      switch (value) {
        case false:
          onChanged(true);
          break;
        case true:
          onChanged(false);
          break;
        default: // case null:
          onChanged(false);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _actionHandler,
      child: _buildCheckBox(),
    );
  }

  Widget _buildCheckBox() {
    if (value) {
      return Icon(Icons.check_circle, color: Color(0xFF3345A9),);
    }
    return Icon(Icons.radio_button_unchecked, color: Colors.black26,);
  }
}
