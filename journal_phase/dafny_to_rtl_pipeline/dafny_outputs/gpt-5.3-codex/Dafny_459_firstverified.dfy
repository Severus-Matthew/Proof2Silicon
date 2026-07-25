// Dafny program demonstrating a clear, iterative implementation with:
// 1) a computation method,
// 2) a check method that verifies correctness properties, and
// 3) a main method that exercises the implementation.

// Compute the sum of all integers from 0 to n (inclusive), iteratively.
// For n >= 0, the expected result is n * (n + 1) / 2.
method SumUpTo(n: nat) returns (sum: nat)
  ensures sum == n * (n + 1) / 2
{
  var i: nat := 0;
  sum := 0;

  // Loop accumulates the running sum while maintaining the closed-form invariant.
  while i <= n
    invariant 0 <= i <= n + 1
    invariant sum == i * (i - 1) / 2
    decreases n + 1 - i
  {
    sum := sum + i;
    i := i + 1;
  }

  // At loop exit, i == n + 1, so invariant implies:
  // sum == (n + 1) * n / 2 == n * (n + 1) / 2.
  assert i == n + 1;
}

// A check method that validates SumUpTo against key properties and examples.
method CheckSumUpTo()
{
  // Concrete example checks
  var s0 := SumUpTo(0);
  assert s0 == 0;

  var s1 := SumUpTo(1);
  assert s1 == 1;

  var s5 := SumUpTo(5);
  assert s5 == 15;

  var s10 := SumUpTo(10);
  assert s10 == 55;

  // Monotonicity sanity check on a small range:
  // SumUpTo(i+1) >= SumUpTo(i)
  var i: nat := 0;
  while i < 20
    invariant 0 <= i <= 20
    decreases 20 - i
  {
    var a := SumUpTo(i);
    var b := SumUpTo(i + 1);
    assert b == a + (i + 1);
    assert b >= a;
    i := i + 1;
  }
}

// Main method to run checks and perform a sample computation.
method Main()
{
  CheckSumUpTo();

  // Sample run value for demonstration.
  var n: nat := 12;
  var result := SumUpTo(n);

  // Postcondition-based expectation, asserted in main as an additional check.
  assert result == n * (n + 1) / 2;
}
