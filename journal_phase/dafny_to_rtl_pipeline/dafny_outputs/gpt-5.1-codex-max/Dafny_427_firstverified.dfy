module Mult {
  method Multiply(x: int, y: int) returns (r: int)
    requires x >= 0 && y >= 0
    ensures r == x * y
  {
    var m: int := x;
    var n: int := y;
    r := 0;
    // Loop invariant maintains that the combination of the partial result r and the remaining
    // repetitions m times n always equals the product of the original inputs.
    while m > 0
      invariant 0 <= m
      invariant r + m * n == x * y
      decreases m
    {
      r := r + n;
      m := m - 1;
    }
    // At this point, m == 0 and r == x * y by the invariant.
    assert m == 0;
  }
}
