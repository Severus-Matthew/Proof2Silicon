// Dafny program to compute the greatest common divisor (GCD) of two non-negative integers
// using the iterative Euclidean algorithm (no recursion in executable code).
// The recursive function `gcd` is used only for specifications and proofs.

/// Mathematical specification of the GCD function.
/// It is defined recursively for clarity in reasoning and contracts.
/// This function is ghost by default and is not compiled into executable code.
function gcd(x: nat, y: nat): nat
  decreases y // Well-founded measure to prove termination of recursion
{
  if y == 0 then x else gcd(y, x % y)
}

/// Method computing the GCD iteratively.
/// This method uses no recursion and maintains an invariant that the GCD of the working
/// pair (a,b) remains equal to the GCD of the original inputs.
method GCDIterative(x: nat, y: nat) returns (g: nat)
  requires x >= 0 && y >= 0
  ensures g == gcd(x, y)
{
  var a := x;
  var b := y;
  // Loop until the remainder becomes zero
  while b != 0
    invariant a >= 0 && b >= 0
    invariant gcd(a, b) == gcd(x, y) // The GCD of the pair remains constant
    decreases b // The second component strictly decreases towards termination
  {
    // Save current values to help in reasoning
    var oldA := a;
    var oldB := b;

    // Since the loop guard enforces b != 0 and b is nat, oldB is positive,
    // making the modulus well-defined and non-negative.
    b := oldA % oldB; // New remainder; strictly less than oldB when oldB > 0
    a := oldB;        // Shift values as per Euclidean step

    // Proof hints:
    // Because oldB != 0, by the definition of gcd, gcd(oldA, oldB) == gcd(oldB, oldA % oldB).
    // After the assignments, (a, b) == (oldB, oldA % oldB), so the invariant holds.
    assert oldB != 0;
    assert gcd(oldA, oldB) == (if oldB == 0 then oldA else gcd(oldB, oldA % oldB));
    assert gcd(a, b) == gcd(x, y);
    // Decrease justification: new b = oldA % oldB < oldB (because oldB > 0),
    // hence the measure 'b' decreases strictly on each iteration.
    assert b < oldB;
  }
  // At this point, b == 0, so by the invariant gcd(a, b) == gcd(x, y) and definition of gcd,
  // the result a is the GCD of the original inputs.
  g := a;
}

/// Simple check function with a few test cases to validate the implementation.
method TestGCD()
{
  // Edge case: both arguments zero
  var r0 := GCDIterative(0, 0);
  assert r0 == 0;
  // One argument zero
  var r1 := GCDIterative(10, 0);
  assert r1 == 10;
  var r2 := GCDIterative(0, 7);
  assert r2 == 7;
  // Co-prime numbers
  var r3 := GCDIterative(17, 13);
  assert r3 == 1;
  // General cases
  var r4 := GCDIterative(54, 24);
  assert r4 == 6;
  var r5 := GCDIterative(48, 180);
  assert r5 == 12;
  var r6 := GCDIterative(8, 12);
  assert r6 == 4;
}

/// Main entry point to run the check function.
/// In a compiled setting, this will print a confirmation if all assertions pass.
method Main()
{
  TestGCD();
  print "All GCD test cases passed!\n";
}
