import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _activeErrorSnackBar;
Timer? _snackBarTimer;

void showErrorSnackBar(BuildContext context, String message) {
  _showSnackBar(
    context: context,
    message: message,
    backgroundColor: Colors.red.shade600,
    icon: Icons.error_outline,
    duration: const Duration(seconds: 4),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  _showSnackBar(
    context: context,
    message: message,
    backgroundColor: Colors.green.shade600,
    icon: Icons.check_circle_outline,
    duration: const Duration(seconds: 3),
  );
}

void _showSnackBar({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
  required IconData icon,
  required Duration duration,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..hideCurrentMaterialBanner();

  _snackBarTimer?.cancel();
  _snackBarTimer = null;
  _activeErrorSnackBar?.remove();
  _activeErrorSnackBar = null;

  final entry = OverlayEntry(
    builder: (overlayContext) => _TopSnackBar(
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      onClose: _removeActiveSnackBar,
    ),
  );

  overlay.insert(entry);
  _activeErrorSnackBar = entry;

  _snackBarTimer = Timer(duration, _removeActiveSnackBar);
}

void _removeActiveSnackBar() {
  _snackBarTimer?.cancel();
  _snackBarTimer = null;
  final entry = _activeErrorSnackBar;
  if (entry != null && entry.mounted) {
    entry.remove();
  }
  _activeErrorSnackBar = null;
}

class _TopSnackBar extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onClose;

  const _TopSnackBar({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onClose,
  });

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: _TopSnackBarBody(
                message: widget.message,
                onClose: widget.onClose,
                backgroundColor: widget.backgroundColor,
                icon: widget.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopSnackBarBody extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final Color backgroundColor;
  final IconData icon;

  const _TopSnackBarBody({
    required this.message,
    required this.onClose,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SizedBox(
            width: double.infinity,
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 16),
                  Icon(icon, color: Colors.white70, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.close, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
