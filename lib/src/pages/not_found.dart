import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:obs_production_switcher/src/app.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  int _countdown = 5;
  late final _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => 5 - i - 1)
        .take(5)
        .listen((count) {
          if (mounted) {
            setState(() {
              _countdown = count;
            });
            if (count == 0) {
              context.go(Routes.landing.path);
            }
          }
        });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Redirecting to Mixer in $_countdown seconds...',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
