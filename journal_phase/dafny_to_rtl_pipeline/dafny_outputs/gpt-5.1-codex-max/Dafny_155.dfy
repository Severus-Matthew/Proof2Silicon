// ============================================================================
// Dafny Program: Iterative Factorial Calculation
// This program computes the factorial of a non-negative integer iteratively.
// It includes a ghost specification function for factorial (used only in specs)
// and an imperative implementation with appropriate contracts and invariants.
// ============================================================================

/// Ghost specification function for factorial.
/// Used only in specifications (pre/postconditions and invariants).
ghost function FactorialSpec(n: nat): nat
  decreases n
{
  if n == 0 then 1 else n * FactorialSpec(n - 1)
}

// -----------------------------------------------------------------------------
// Method: Factorial
// Purpose : Compute the factorial of a non-negative integer iteratively.
// Input   : n - a natural number (nat) for which to compute the factorial.
// Output  : res - the factorial of n, satisfying res == FactorialSpec(n).
// Contracts:
//   - Precondition: n is a non-negative integer (ensured by type nat).
//   - Postcondition: res equals the mathematical factorial of n.
//   - Loop invariants ensure correctness throughout the computation.
// -----------------------------------------------------------------------------
method Factorial(n: nat) returns (res: nat)
  ensures res == FactorialSpec(n)
{
  var i: nat := 0; // Counts how many factors have been multiplied so far
  res := 1;        // Initialize result (0! = 1)

  // Loop to multiply res by each integer from 1 up to n
  while i < n
    invariant i <= n
    invariant res == FactorialSpec(i)
    decreases n - i
  {
    i := i + 1;
    res := res * i;
    // Invariant maintained: res == FactorialSpec(i)
  }
  // Upon loop exit, i == n, so res == FactorialSpec(n) by the invariant.
}

// -----------------------------------------------------------------------------
// Method: Main
// Purpose: Entry point demonstrating the factorial computation.
// -----------------------------------------------------------------------------
method Main()
{
  var n: nat := 5;       // Example input
  var f := Factorial(n); // Compute factorial iteratively
  print "Factorial of ", n, " is ", f, "\n";
}
