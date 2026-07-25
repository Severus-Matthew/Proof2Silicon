// This program computes the factorial of a non-negative integer using an iterative loop.
// It avoids recursion in executable code, but uses a simple recursive function for specification.
// The loop invariants and asserts help Dafny verify correctness.

function factSpec(n: nat): nat
  decreases n
{
  if n == 0 then 1 else n * factSpec(n - 1)
}

method Factorial(n: nat) returns (res: nat)
  requires n >= 0
  ensures res == factSpec(n) // postcondition: the result matches the mathematical factorial
  ensures res > 0            // factorial of any nat is positive
{
  var i: nat := 0;
  var prod: nat := 1;
  // Initial state: i == 0 and prod == factSpec(0) == 1

  while i < n
    invariant i <= n
    invariant prod == factSpec(i) // the product so far equals i!
    invariant prod > 0            // product stays positive
    decreases n - i               // termination argument: n - i decreases each iteration
  {
    // Increase the counter first; we will maintain the invariant after updates
    i := i + 1;
    // i is now at least 1, so i - 1 is a valid nat
    assert i > 0;

    // Update the product to include the new i
    prod := prod * i;

    // Help the verifier by unfolding the definition of factSpec when i > 0
    assert factSpec(i) == i * factSpec(i - 1);

    // After the updates, re-establish the invariant prod == factSpec(i)
    assert prod == factSpec(i);
  }

  res := prod;
  // At this point, i == n and prod == factSpec(n), so the postconditions hold.
}

// A simple demonstration method; not required for verification.
// It shows how to call Factorial and check the result.
method Main()
{
  var value: nat := 5;
  var fact: nat := Factorial(value);
  assert fact == factSpec(value);
  // Remember: ensure your inputs satisfy preconditions (e.g., non-negative) to avoid common pitfalls.
}
