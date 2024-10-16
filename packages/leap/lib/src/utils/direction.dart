enum HorizontalDirection {
  left,
  right,
}

extension HorizontalDirectionExtension on HorizontalDirection {
  HorizontalDirection flip() {
    if (this == HorizontalDirection.left) {
      return HorizontalDirection.right;
    } else {
      return HorizontalDirection.left;
    }
  }
}

enum VerticalDirection {
  up,
  down,
}

extension VerticalDirectionExtension on VerticalDirection {
  VerticalDirection flip() {
    if (this == VerticalDirection.up) {
      return VerticalDirection.down;
    } else {
      return VerticalDirection.up;
    }
  }
}
