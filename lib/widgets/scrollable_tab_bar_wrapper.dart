import 'package:flutter/material.dart';

/// Wraps a scrollable [TabBar] with left/right arrow buttons that fade in/out
/// based on whether there is more content to scroll in that direction.
///
/// **Drop-in usage** — replaces your plain `TabBar` inside `AppBar.bottom`:
///
/// ```dart
/// AppBar(
///   title: Text('Inventory'),
///   bottom: ScrollableTabBarWrapper(
///     tabController: _tabController,
///     tabs: _categories.map((cat) => Tab(child: ...)).toList(),
///     indicatorColor: Colors.deepPurple,
///     labelColor: Colors.deepPurple,
///     unselectedLabelColor: Colors.grey[600],
///   ),
/// )
/// ```
///
/// Implements [PreferredSizeWidget] so it fits [AppBar.bottom] directly.
class ScrollableTabBarWrapper extends StatefulWidget
    implements PreferredSizeWidget {
  const ScrollableTabBarWrapper({
    super.key,
    required this.tabController,
    required this.tabs,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 3.0,
    this.tabBarHeight = 48.0,
  });

  final TabController tabController;
  final List<Widget> tabs;

  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double indicatorWeight;

  /// Height reserved for [preferredSize]; must match [TabBar] height.
  final double tabBarHeight;

  @override
  Size get preferredSize => Size.fromHeight(tabBarHeight);

  @override
  State<ScrollableTabBarWrapper> createState() =>
      _ScrollableTabBarWrapperState();
}

class _ScrollableTabBarWrapperState extends State<ScrollableTabBarWrapper> {
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  /// We grab the TabBar's internal scroll position via NotificationListener.
  /// But we also need a way to programmatically scroll it. The trick: we
  /// attach our own ScrollController via [ScrollConfiguration] override,
  /// which Flutter's scrollable TabBar will pick up.
  late final ScrollController _sc;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
    _sc.addListener(_onScroll);
    // After first frame, check whether right arrow is needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small delay to let TabBar lay out
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _onScroll();
      });
    });
  }

  @override
  void dispose() {
    _sc.removeListener(_onScroll);
    _sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_sc.hasClients) return;
    final pos = _sc.position;
    final left = pos.pixels > 2;
    final right = pos.pixels < pos.maxScrollExtent - 2;
    if (left != _canScrollLeft || right != _canScrollRight) {
      if (mounted) {
        setState(() {
          _canScrollLeft = left;
          _canScrollRight = right;
        });
      }
    }
  }

  void _scroll(double delta) {
    if (!_sc.hasClients) return;
    _sc.animateTo(
      (_sc.offset + delta).clamp(
        _sc.position.minScrollExtent,
        _sc.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Match the AppBar background for gradient fade
    final bg = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    return SizedBox(
      height: widget.tabBarHeight,
      child: Stack(
        children: [
          // Inject our ScrollController into TabBar's internal Scrollable
          // by overriding the PrimaryScrollController for this subtree.
          PrimaryScrollController(
            controller: _sc,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                // Belt-and-suspenders: also update via notifications
                // for cases where our SC didn't attach.
                if (n is ScrollUpdateNotification ||
                    n is ScrollEndNotification) {
                  final metrics = n.metrics;
                  final left = metrics.pixels > 2;
                  final right =
                      metrics.pixels < metrics.maxScrollExtent - 2;
                  if (left != _canScrollLeft ||
                      right != _canScrollRight) {
                    if (mounted) {
                      setState(() {
                        _canScrollLeft = left;
                        _canScrollRight = right;
                      });
                    }
                  }
                }
                return false;
              },
              child: TabBar(
                controller: widget.tabController,
                isScrollable: true,
                // DO NOT pass a scrollController here — let Flutter pick up
                // _sc from PrimaryScrollController above.
                indicatorColor: widget.indicatorColor,
                labelColor: widget.labelColor,
                unselectedLabelColor: widget.unselectedLabelColor,
                indicatorWeight: widget.indicatorWeight,
                tabs: widget.tabs,
              ),
            ),
          ),

          // Left fade + arrow
          AnimatedOpacity(
            opacity: _canScrollLeft ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_canScrollLeft,
              child: _EdgeButton(
                side: AxisDirection.left,
                bg: bg,
                arrowColor: widget.indicatorColor ?? Colors.deepPurple,
                onTap: () => _scroll(-160),
              ),
            ),
          ),

          // Right fade + arrow
          AnimatedOpacity(
            opacity: _canScrollRight ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_canScrollRight,
              child: _EdgeButton(
                side: AxisDirection.right,
                bg: bg,
                arrowColor: widget.indicatorColor ?? Colors.deepPurple,
                onTap: () => _scroll(160),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Gradient fade + chevron overlay on one side of the tab bar.
class _EdgeButton extends StatelessWidget {
  const _EdgeButton({
    required this.side,
    required this.bg,
    required this.arrowColor,
    required this.onTap,
  });

  final AxisDirection side;
  final Color bg;
  final Color arrowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLeft = side == AxisDirection.left;

    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [bg, bg.withOpacity(0.0)],
              stops: const [0.55, 1.0],
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 20,
            color: arrowColor,
          ),
        ),
      ),
    );
  }
}