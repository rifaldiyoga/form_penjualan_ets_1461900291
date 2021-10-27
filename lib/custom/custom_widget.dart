import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TextStyle defaultFontStyle = TextStyle(fontSize: 16);

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController? controller;
  final Function? onTap;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final TextInputType? textInputType;
  final FocusNode? focusNode;
  final String? initValue;

  const CustomTextField(
      {Key? key,
      required this.hintText,
      required this.labelText,
      this.controller,
      this.textInputType,
      this.validator,
      this.initValue,
      this.focusNode,
      this.textInputAction,
      this.onTap})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onTap: () {
        widget.onTap!();
      },
      // initialValue: widget.initValue,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      validator: widget.validator == null
          ? (data) {
              if (data.toString().isEmpty)
                return "${widget.labelText} tidak boleh kosong";
            }
          : widget.validator,
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          border: OutlineInputBorder()),
    );
  }
}

class CustomDropDown extends StatefulWidget {
  final List<String> itemList;
  final String value;
  final Function(String?)? onChanged;

  const CustomDropDown(
      {Key? key,
      required this.value,
      required this.itemList,
      required this.onChanged})
      : super(key: key);

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    print(widget.itemList);
    return DropdownButton<String>(
      value: widget.value,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: widget.onChanged,
      items: widget.itemList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text(
                value,
              )),
        );
      }).toList(),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            // Checkbox(
            //   value: value,
            //   onChanged: onChangeds,
            // ),
            Expanded(child: Text(label))
          ],
        ),
      ),
    );
  }
}
