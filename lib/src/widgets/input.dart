import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final bool obscureText;
  const TextInput({
    this.controller,
    this.labelText,
    this.obscureText = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
    );
  }
}

class PortField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  const PortField({this.controller, this.labelText, super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number, // Only allows numeric input
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Only digits are allowed
        LengthLimitingTextInputFormatter(5), // Maximum 5 digits
      ],
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;

  const PasswordField({this.controller, String? labelText, super.key})
    : labelText = labelText ?? "password";
  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }
}
