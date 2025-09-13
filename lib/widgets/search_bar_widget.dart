import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(),
        decoration: InputDecoration(
          hintText: 'Search debts by name, email, or phone...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                    onClear?.call();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade500,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
