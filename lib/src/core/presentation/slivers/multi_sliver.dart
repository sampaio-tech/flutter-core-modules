import 'package:flutter/widgets.dart';

import 'rendering/multi_sliver.dart';

/// [MultiSliver] allows for returning multiple slivers from a single build method
class MultiSliver extends MultiChildRenderObjectWidget {
  // flutter pre 3.13 does not allow the constructor to be const
  // ignore: prefer_const_constructors_in_immutables
  MultiSliver({
    required List<Widget> children,
    Key? key,
    this.pushPinnedChildren = false,
  }) : super(key: key, children: children);

  /// If true any children that paint beyond the layoutExtent of the entire [MultiSliver] will
  /// be pushed off towards the leading edge of the [Viewport]
  final bool pushPinnedChildren;

  @override
  RenderMultiSliver createRenderObject(BuildContext context) =>
      RenderMultiSliver(
        containing: pushPinnedChildren,
      );

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderMultiSliver renderObject) {
    renderObject.containing = pushPinnedChildren;
  }
}
