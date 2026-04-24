import 'package:flutter/material.dart';

/// A scrollable tab bar strip where the left/right arrow buttons scroll the
/// visible area WITHOUT changing the selected tab. Tapping a tab still
/// selects it via [tabController].
///
/// Because Flutter's built-in [TabBar] never exposes its internal
/// [ScrollController], this widget renders the tab strip manually inside a
/// [SingleChildScrollView] that we own — so arrow taps reliably move it.
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

  /// Height of the widget; pass a larger value if your tabs are taller.
  final double tabBarHeight;

  @override
  Size get preferredSize => Size.fromHeight(tabBarHeight);

  @override
  State<ScrollableTabBarWrapper> createState() =>
      _ScrollableTabBarWrapperState();
}

class _ScrollableTabBarWrapperState extends State<ScrollableTabBarWrapper> {
  late final ScrollController _sc;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
    _sc.addListener(_updateArrows);
    _selectedIndex = widget.tabController.index;
    widget.tabController.addListener(_onTabControllerChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), _updateArrows);
    });
  }

  @override
  void dispose() {
    _sc.removeListener(_updateArrows);
    _sc.dispose();
    widget.tabController.removeListener(_onTabControllerChange);
    super.dispose();
  }

  void _onTabControllerChange() {
    if (widget.tabController.indexIsChanging ||
        widget.tabController.index != _selectedIndex) {
      if (mounted) {
        setState(() => _selectedIndex = widget.tabController.index);
      }
    }
  }

  void _updateArrows() {
    if (!_sc.hasClients) return;
    final pos = _sc.position;
    final left = pos.pixels > 2;
    final right = pos.pixels < pos.maxScrollExtent - 2;
    if (left != _canScrollLeft || right != _canScrollRight) {
      if (mounted) setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  void _scrollBy(double delta) {
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

  void _selectTab(int index) {
    widget.tabController.animateTo(index);
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor =
        widget.indicatorColor ?? Theme.of(context).colorScheme.primary;
    final labelColor =
        widget.labelColor ?? Theme.of(context).colorScheme.primary;
    final unselectedColor =
        widget.unselectedLabelColor ?? Colors.grey[500]!;

    // Try to get the app bar background for the gradient fade.
    final bg = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    return SizedBox(
      height: widget.tabBarHeight,
      child: Stack(
        children: [
          // ── Custom tab strip ──────────────────────────────────────
          SingleChildScrollView(
            controller: _sc,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(widget.tabs.length, (i) {
                  final isSelected = i == _selectedIndex;
                  return _TabItem(
                    child: widget.tabs[i],
                    isSelected: isSelected,
                    labelColor: labelColor,
                    unselectedColor: unselectedColor,
                    indicatorColor: indicatorColor,
                    indicatorWeight: widget.indicatorWeight,
                    onTap: () => _selectTab(i),
                  );
                }),
              ),
            ),
          ),

          // ── Left arrow ────────────────────────────────────────────
          _EdgeButton(
            isLeft: true,
            bg: bg,
            arrowColor: _canScrollLeft
                ? indicatorColor
                : indicatorColor.withOpacity(0.25),
            onTap: () => _scrollBy(-160),
          ),

          // ── Right arrow ───────────────────────────────────────────
          _EdgeButton(
            isLeft: false,
            bg: bg,
            arrowColor: _canScrollRight
                ? indicatorColor
                : indicatorColor.withOpacity(0.25),
            onTap: () => _scrollBy(160),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.child,
    required this.isSelected,
    required this.labelColor,
    required this.unselectedColor,
    required this.indicatorColor,
    required this.indicatorWeight,
    required this.onTap,
  });

  final Widget child;
  final bool isSelected;
  final Color labelColor;
  final Color unselectedColor;
  final Color indicatorColor;
  final double indicatorWeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? indicatorColor : Colors.transparent,
              width: indicatorWeight,
            ),
          ),
        ),
        child: Center(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: isSelected ? labelColor : unselectedColor,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: isSelected ? labelColor : unselectedColor,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EdgeButton extends StatelessWidget {
  const _EdgeButton({
    required this.isLeft,
    required this.bg,
    required this.arrowColor,
    required this.onTap,
  });

  final bool isLeft;
  final Color bg;
  final Color arrowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              begin:
                  isLeft ? Alignment.centerLeft : Alignment.centerRight,
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