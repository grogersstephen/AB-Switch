import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
export 'package:flutter/material.dart' show Colors;

class SnackbarMessage {
  final String message;
  final Color _backgroundColor;
  const SnackbarMessage(this.message, {Color? backgroundColor})
      : _backgroundColor = backgroundColor ?? Colors.green;
}

class SnackbarListener extends HookWidget {
  final Stream<SnackbarMessage> stream;
  final Widget child;
  const SnackbarListener(
      {required this.child, required this.stream, super.key});
  @override
  Widget build(BuildContext context) {
    final snackbarMessage = useState<SnackbarMessage?>(null);
    useEffect(() {
      final sub = stream.listen((event) {
        snackbarMessage.value = event;
      });
      return sub.cancel;
    }, []);
    // Listen for snackbar updates
    final value = snackbarMessage.value;
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value.message, textAlign: TextAlign.center),
          duration: const Duration(seconds: 4),
          backgroundColor: value._backgroundColor,
        ),
      );
    }
    return child;
  }
}
