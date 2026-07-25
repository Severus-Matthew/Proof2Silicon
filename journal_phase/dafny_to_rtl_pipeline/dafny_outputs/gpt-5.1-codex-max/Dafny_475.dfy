module Factorial {

  // A pure mathematical definition of factorial, used for specifications
  ghost function mathFactorial(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * mathFactorial(n - 1)
  }

  // An iterative method computing factorial without recursion
  method Fat(n: nat) returns (res: nat)
    requires n >= 0
    ensures res == mathFactorial(n)
  {
    var i: nat := 0;
    res := 1;
    // Loop invariant tracks that res == i!
    while i < n
      invariant 0 <= i <= n
      invariant res == mathFactorial(i)
      decreases n - i
    {
      i := i + 1;
      res := res * i;
    }
  }

  // A method to demonstrate usage and verification
  method Compute(n: nat) returns (res: nat)
    requires n >= 0
    ensures res == mathFactorial(n)
  {
    res := Fat(n);
    // Verification step: res should be equal to mathFactorial(n)
    assert res == mathFactorial(n);
  }
}
