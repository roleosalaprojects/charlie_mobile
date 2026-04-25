import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/helpers.dart';

enum ToastType { success, error, warning, info }

/// Compact bottom-centered toast. Dark pill, colored icon, short auto-dismiss.
///
/// Usage:
///   AppToast.error(context, 'Failed to submit', message: 'Check your connection.');
///   AppToast.success(context, 'Saved');
class AppToast {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void success(BuildContext context, String title, {String? message, Duration? duration}) =>
      _show(context, ToastType.success, title, message, duration ?? const Duration(seconds: 2));

  static void error(BuildContext context, String title, {String? message, Duration? duration}) =>
      _show(context, ToastType.error, title, message, duration ?? const Duration(seconds: 3));

  static void warning(BuildContext context, String title, {String? message, Duration? duration}) =>
      _show(context, ToastType.warning, title, message, duration ?? const Duration(milliseconds: 2500));

  static void info(BuildContext context, String title, {String? message, Duration? duration}) =>
      _show(context, ToastType.info, title, message, duration ?? const Duration(seconds: 2));

  static void _show(BuildContext context, ToastType type, String title, String? message, Duration duration) {
    // Defer overlay mutation to post-frame so we never mutate mid-paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _removeNow();

      final overlay = Overlay.of(context);
      final entry = OverlayEntry(
        builder: (_) => _ToastHost(
          type: type,
          title: title,
          message: message,
          onClose: dismiss,
        ),
      );

      _current = entry;
      overlay.insert(entry);
      _timer = Timer(duration, dismiss);
    });
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _removeNow());
  }

  static void _removeNow() {
    final entry = _current;
    _current = null;
    if (entry == null) return;
    try {
      entry.remove();
    } catch (_) {}
  }
}

class _ToastHost extends StatefulWidget {
  final ToastType type;
  final String title;
  final String? message;
  final VoidCallback onClose;

  const _ToastHost({required this.type, required this.title, this.message, required this.onClose});

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..forward();
    _slide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = _spec(widget.type);
    final hasMessage = widget.message != null && widget.message!.isNotEmpty;

    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 90,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _close,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A), // slate-900
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: spec.color.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(spec.icon, color: spec.color, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                              if (hasMessage) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.message!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _Spec _spec(ToastType t) {
    switch (t) {
      case ToastType.success:
        return _Spec(AppColors.success, Icons.check_rounded);
      case ToastType.error:
        return _Spec(AppColors.danger, Icons.close_rounded);
      case ToastType.warning:
        return _Spec(AppColors.warning, Icons.priority_high_rounded);
      case ToastType.info:
        return _Spec(AppColors.info, Icons.info_outline_rounded);
    }
  }
}

class _Spec {
  final Color color;
  final IconData icon;
  _Spec(this.color, this.icon);
}
