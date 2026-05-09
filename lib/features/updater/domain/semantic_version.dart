class SemanticVersion implements Comparable<SemanticVersion> {
  final int major;
  final int minor;
  final int patch;
  final List<String> preRelease;

  const SemanticVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease = const <String>[],
  });

  factory SemanticVersion.parse(String value) {
    final cleaned = value.trim().replaceFirst(RegExp(r'^v'), '');
    final withoutBuild = cleaned.split('+').first;
    final parts = withoutBuild.split('-');
    final numbers = parts.first.split('.');
    if (numbers.length < 3) {
      throw FormatException('Version must use major.minor.patch', value);
    }
    return SemanticVersion(
      major: int.parse(numbers[0]),
      minor: int.parse(numbers[1]),
      patch: int.parse(numbers[2]),
      preRelease: parts.length > 1 ? parts[1].split('.') : const <String>[],
    );
  }

  @override
  int compareTo(SemanticVersion other) {
    final majorCompare = major.compareTo(other.major);
    if (majorCompare != 0) return majorCompare;
    final minorCompare = minor.compareTo(other.minor);
    if (minorCompare != 0) return minorCompare;
    final patchCompare = patch.compareTo(other.patch);
    if (patchCompare != 0) return patchCompare;
    return _comparePreRelease(other);
  }

  int _comparePreRelease(SemanticVersion other) {
    if (preRelease.isEmpty && other.preRelease.isEmpty) return 0;
    if (preRelease.isEmpty) return 1;
    if (other.preRelease.isEmpty) return -1;

    final maxLength = preRelease.length > other.preRelease.length
        ? preRelease.length
        : other.preRelease.length;
    for (var i = 0; i < maxLength; i++) {
      if (i >= preRelease.length) return -1;
      if (i >= other.preRelease.length) return 1;

      final left = preRelease[i];
      final right = other.preRelease[i];
      final leftNumber = int.tryParse(left);
      final rightNumber = int.tryParse(right);

      if (leftNumber != null && rightNumber != null) {
        final comparison = leftNumber.compareTo(rightNumber);
        if (comparison != 0) return comparison;
      } else if (leftNumber != null) {
        return -1;
      } else if (rightNumber != null) {
        return 1;
      } else {
        final comparison = left.compareTo(right);
        if (comparison != 0) return comparison;
      }
    }
    return 0;
  }

  @override
  String toString() {
    final base = '$major.$minor.$patch';
    return preRelease.isEmpty ? base : '$base-${preRelease.join('.')}';
  }
}
