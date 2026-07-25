module SquareEvaluation {

  /// A simple pure function that returns the sum of its two integer arguments.
  function sum(a: int, b: int): int {
    a + b
  }

  /// Computes the square of a non-negative integer `x` by repeated addition,
  /// and also returns the sum of `x` with itself.
  method ComputeSquare(x: nat) returns (r: int, z: int)
    ensures r == x * x
    ensures z == sum(x, x)
  {
    var acc: int := 0;
    var i: nat := 0;

    // Compute x * x by adding x to itself x times.
    while i < x
      invariant 0 <= i <= x
      invariant acc == i * x
      decreases x - i
    {
      acc := acc + x;
      i := i + 1;
    }

    r := acc;
    z := sum(x, x);
  }

  // Test the method with a non-negative integer.
  method Test(x: nat) {
    var r, z := ComputeSquare(x);
    assert r == x * x;
    assert z == sum(x, x);
  }

}
