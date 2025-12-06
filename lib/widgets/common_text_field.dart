import 'package:flutter/material.dart';
import 'package:trackers_app/utils/extensions.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField(
      {super.key,
      required this.title,
      required this.hintText,
      this.controller,
      this.maxLines,
      this.suffixIcon,
      this.readOnly = false});
  final String title;
  final int? maxLines;
  final Widget? suffixIcon;
  final String hintText;
  final bool readOnly;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        TextField(
          readOnly: readOnly,
          controller: controller,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          maxLines: maxLines,
          decoration: InputDecoration(
            //labelText: 'Task Name',
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            //fillColor: colors.primaryContainer.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.deepPurple),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.deepPurple),
            ),
          ),
          onChanged: (value) {},
        ),
      ],
    );
  }
}
