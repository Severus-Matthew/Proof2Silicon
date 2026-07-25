module Max {
  /// A simple, non-recursive function that returns the maximum of two integers.
  function Max(a: int, b: int): int
    ensures Max(a, b) >= a && Max(a, b) >= b
    ensures Max(a, b) == (if a >= b then a else b)
  {
    if a >= b then a else b
  }

  /// Compute the maximum of two integers.
  method ComputeMax(a: int, b: int) returns (c: int)
    ensures c >= a && c >= b
    ensures c == Max(a, b)
  {
    if a >= b {
      c := a;
    } else {
      c := b;
    }
  }
}
