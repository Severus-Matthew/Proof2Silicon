// A simple Dafny program that computes the factorial of a non-negative integer
// using an iterative loop. The program includes a specification function for
// factorial used in contracts, and an iterative implementation with appropriate
// loop invariants and termination arguments. A Main method demonstrates usage.

// Specification of factorial as a (ghost) function for use in contracts.
// This function is recursive but is used only in specifications, not in
// executable code.
function factorialSpec(n: nat): nat
  decreases n
{
  if n == 0 then 1 else n * factorialSpec(n - 1)
}

// Iterative implementation of factorial.
// The method avoids recursion and uses a while loop with invariants to prove correctness.
method Factorial(n: nat) returns (res: nat)
  ensures res == factorialSpec(n)
{
  var i: nat := 0;
  var acc: nat := 1;
  // Invariant 1: 0 <= i <= n keeps the loop counter within bounds.
  // Invariant 2: acc == factorialSpec(i) ensures accumulator holds i! at each iteration.
  while i < n
    invariant 0 <= i <= n
    invariant acc == factorialSpec(i)
    decreases n - i
  {
    i := i + 1;
    acc := acc * i;
  }
  // At loop exit, i == n and acc == factorialSpec(n), so assign to result.
  res := acc;
}

// Main entry point demonstrating the Factorial method.
// In a realistic scenario, n could be obtained from user input or another source.
method Main()
{
  var n: nat := 5;
  var f := Factorial(n);
  // Output the result in a human-readable form.
  print "Factorial of ", n, " is ", f, "\n";
}
