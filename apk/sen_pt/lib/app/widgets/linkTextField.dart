import 'package:flutter/material.dart';

class LinkTextField extends StatefulWidget {
  const LinkTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<LinkTextField> createState() => _LinkTextFieldState();
}

class _LinkTextFieldState extends State<LinkTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: _isFocused
                ? const Color(0xFF6C63FF)
                : const Color(0xFFE0E0E6),
            width: _isFocused ? 1.8 : 1.2,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.link_rounded,
                color: _isFocused
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFFAAAAAA),
                size: 22,
              ),
            ),
            hintText: 'Inputkan Link Produk',
            hintStyle: const TextStyle(
              color: Color(0xFFBBBBC5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }
}
