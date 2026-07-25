// This Dafny program demonstrates how to compute the factorial of a non-negative integer
// using an iterative approach. It includes precise specifications, loop invariants,
// and comments explaining the logic, potential edge cases, and common pitfalls.
// Recursion is deliberately avoided to comply with the requirement.

module FactorialModule {

  // Mathematical definition of factorial used for specification purposes only.
  // This function is total over nat and is not used for computation in the implementation.
  function factorial(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * factorial(n - 1)
  }

  // Iterative method to compute factorial. Avoids recursion to prevent stack overflow
  // and to adhere to the instruction to avoid recursion.
  method FactorialIterative(n: nat) returns (result: nat)
    requires n >= 0 // Precondition: n must be non-negative (nat enforces this)
    ensures result == factorial(n) // Postcondition: result matches the mathematical definition
  {
    // Handle edge case explicitly: 0! = 1
    result := 1;
    var i: nat := 1;

    // Invariant explanation:
    // - 1 <= i <= n + 1: loop counter stays within bounds.
    // - result == factorial(i - 1): result holds the factorial of the number just below i.
    // The loop will terminate when i == n + 1, at which point result == factorial(n).
    while i <= n
      invariant 1 <= i <= n + 1
      invariant result == factorial(i - 1)
      decreases n - i + 1
    {
      // Multiply the current result by i to build up factorial iteratively.
      result := result * i;
      // Increment loop counter.
      i := i + 1;
    }

    // At loop exit, i == n + 1 and result == factorial((n + 1) - 1) == factorial(n).
    // Therefore, postcondition holds.
  }

  // Simple main-like method to demonstrate usage (not required by problem statement).
  // Includes an assertion to validate that FactorialIterative meets its specification.
  method Demo()
  {
    var n: nat := 5;
    var res := FactorialIterative(n);
    assert res == 120; // 5! = 120
  }

  // Common pitfalls to avoid:
  // - Off-by-one errors in loop bounds (ensure loop runs exactly n times).
  // - Forgetting to initialize the result correctly (must start at 1).
  // - Missing or incorrect invariants that are needed for verification.
  // Suggestion: Prefer iterative solutions with well-specified invariants over recursion
  // to avoid deep call stacks and to simplify verification in Dafny.
}
