module Arithmetic {

  method SumUp(n: nat) returns (sum: nat)
    ensures sum == n * (n + 1) / 2
  {
    var i: nat := 1;
    sum := 0;
    while i <= n
      invariant 1 <= i
      invariant i <= n + 1
      invariant sum == (i - 1) * i / 2
      invariant sum >= 0
      decreases n - i + 1
    {
      sum := sum + i;
      i := i + 1;
    }
  }
}
