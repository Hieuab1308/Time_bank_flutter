import 'package:flutter/material.dart';

/// A horizontal separator line with a soft drop shadow to visually break sections.
class ShadowSeparator extends StatelessWidget {
  const ShadowSeparator({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 4, 16, 12),
      height: 14, // container to host shadow
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
