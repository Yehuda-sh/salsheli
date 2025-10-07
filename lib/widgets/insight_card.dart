// lib/widgets/insight_card.dart

import 'package:flutter/material.dart';

class InsightCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final String? description;
  final Map<String, dynamic>?
  badge; // { "emoji": "🔥", "title": "חשוב", "color": Colors.red }
  final Color? color;
  final Color? iconColor;
  final double delay;
  final String? tooltip;
  final Widget? child;

  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    this.value = "—",
    this.subtitle,
    this.description,
    this.badge,
    this.color,
    this.iconColor,
    this.delay = 0,
    this.tooltip,
    this.child,
  });

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? Colors.blueGrey.shade900.withValues(alpha: 0.9);
    final iconColor = widget.iconColor ?? Colors.amber;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(0, isHovered ? -2 : 0, 0),
            child: Card(
              color: cardColor,
              elevation: isHovered ? 8 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade700, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔝 Header: title + icon + badge + tooltip
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(widget.icon, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.tooltip != null)
                          Tooltip(
                            message: widget.tooltip!,
                            child: const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        if (widget.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.badge!["color"] as Color? ??
                                  Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  widget.badge!["emoji"] ?? "",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.badge!["title"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔢 Main value
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),

                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    if (widget.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (widget.child != null) ...[
                      const SizedBox(height: 12),
                      widget.child!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
