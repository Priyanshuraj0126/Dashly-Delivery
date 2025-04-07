import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CustomInfiniteScroll extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool showScrollbar;
  final bool showScrollbarWhenDragging;
  final double scrollbarThickness;
  final Color? scrollbarColor;
  final Color? scrollbarTrackColor;
  final Color? scrollbarTrackBorderColor;
  final double scrollbarTrackBorderWidth;
  final double scrollbarTrackBorderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double threshold;
  final bool reverse;
  final bool primary;
  final bool shrinkWrap;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;

  const CustomInfiniteScroll({
    super.key,
    required this.child,
    required this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.controller,
    this.physics,
    this.showScrollbar = false,
    this.showScrollbarWhenDragging = true,
    this.scrollbarThickness = 6.0,
    this.scrollbarColor,
    this.scrollbarTrackColor,
    this.scrollbarTrackBorderColor,
    this.scrollbarTrackBorderWidth = 1.0,
    this.scrollbarTrackBorderRadius = 3.0,
    this.padding,
    this.margin,
    this.threshold = 0.8,
    this.reverse = false,
    this.primary = false,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
  });

  @override
  State<CustomInfiniteScroll> createState() => _CustomInfiniteScrollState();
}

class _CustomInfiniteScrollState extends State<CustomInfiniteScroll> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * widget.threshold) {
      if (!_isLoadingMore && widget.hasMore && !widget.isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }
    if (widget.margin != null) {
      content = Container(margin: widget.margin!, child: content);
    }

    if (widget.showScrollbar) {
      content = Scrollbar(
        controller: _scrollController,
        thickness: widget.scrollbarThickness,
        radius: Radius.circular(widget.scrollbarTrackBorderRadius),
        child: content,
      );
    }

    return ListView(
      controller: _scrollController,
      physics: widget.physics,
      reverse: widget.reverse,
      primary: widget.primary,
      shrinkWrap: widget.shrinkWrap,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      children: [
        content,
        if (widget.hasMore && (widget.isLoading || _isLoadingMore))
          widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        if (!widget.hasMore && widget.emptyWidget != null) widget.emptyWidget!,
        if (widget.errorWidget != null) widget.errorWidget!,
      ],
    );
  }
}
