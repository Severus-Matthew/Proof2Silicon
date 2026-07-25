module OctagonalNumber {

  /// Computes the nth octagonal number, defined by the formula n * (3*n - 2).
  /// The input `n` is a natural number (non-negative), and the result is also non-negative.
  method ComputeOctagonal(n: nat) returns (result: nat)
    ensures result == n * (3 * n - 2)
    ensures result >= 0
  {
    if n == 0 {
      // For n == 0, the formula yields 0 * (3*0 - 2) == 0
      result := 0;
    } else {
      // For n > 0, we have 3*n >= 3, so (3*n - 2) >= 1
      assert 3 * n - 2 >= 1;
      // Thus the product n * (3*n - 2) is non-negative
      result := n * (3 * n - 2);
    }
  }

}
