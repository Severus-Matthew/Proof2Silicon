module Abs {

  // Use the following Dafny constructs to implement the logic:
  // module, method, requires, ensures, if-then-else, assignment, assertions.

  // Returns the absolute value of x.
  method Abs(x: int) returns (y: int)
    ensures y >= 0
    ensures y == x || y == -x
    ensures x >= 0 ==> y == x
    ensures x < 0  ==> y == -x
  {
    // Conditional logic to compute absolute value.
    if x < 0 {
      y := -x;
      // In this branch, x is negative, so y is non-negative and equals -x.
      assert y == -x;
      assert y >= 0;
    } else {
      y := x;
      // In this branch, x is non-negative, so y equals x and is non-negative.
      assert y == x;
      assert y >= 0;
    }

    // Common post-state fact.
    assert y == x || y == -x;
  }

  // Returns the maximum of a and b.
  method Max(a: int, b: int) returns (c: int)
    ensures c >= a && c >= b
    ensures c == a || c == b
    ensures a >= b ==> c == a
    ensures b > a  ==> c == b
  {
    // Conditional selection of the larger value.
    if a >= b {
      c := a;
      // If a is at least b, max is a.
      assert c == a;
      assert c >= b;
    } else {
      c := b;
      // Otherwise b is strictly greater than a, so max is b.
      assert c == b;
      assert c > a;
    }

    // Common post-state fact.
    assert c == a || c == b;
  }
}
