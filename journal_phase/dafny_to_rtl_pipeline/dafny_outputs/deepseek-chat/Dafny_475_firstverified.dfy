module Fat {

  // Compute factorial iteratively
  function Factorial(n: nat): nat
    ensures Factorial(n) == Fat(n)
  {
    if n == 0 then 1 else n * Factorial(n - 1)
  }

  // Recursive definition for comparison
  function Fat(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * Fat(n - 1)
  }

  // Verify that Factorial(n) == Fat(n) for all n
  lemma FactorialEqualsFat(n: nat)
    ensures Factorial(n) == Fat(n)
  {
    if n == 0 {
      // Base case: both return 1
    } else {
      // Inductive step
      FactorialEqualsFat(n - 1);
    }
  }
}
