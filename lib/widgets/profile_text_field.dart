import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final String? hint;
  final TextInputType? inputType;
  final Function(String)? onChanged; // Callback để xử lý khi gõ phím

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.hint,
    this.inputType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: inputType,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged, // Gắn hàm callback vào đây
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: readOnly
                ? const Color(0xFF1E293B).withOpacity(0.5)
                : const Color(0xFF1E293B),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
