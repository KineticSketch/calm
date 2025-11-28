import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../providers/signin_provider.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controller.isAnimating) return;

    _controller.forward(from: 0.0).then((_) {
      context.read<SignInProvider>().addSignIn();
      toastification.show(
        context: context,
        title: const Text('签到成功!'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.topCenter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>();
    final todayCount = provider.getCountForDay(DateTime.now());

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Count display above button
            Text(
              '今日: $todayCount 次',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Sign-in button
            GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Static container with text
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.8),
                              Theme.of(context).primaryColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.6)
                                  : Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border:
                              Theme.of(context).brightness == Brightness.dark
                              ? Border.all(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.5),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: const Center(
                          child: Text(
                            '打卡',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Rotating dot indicator
                      Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: Transform.translate(
                          offset: const Offset(0, -80),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
