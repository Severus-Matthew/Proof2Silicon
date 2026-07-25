method NthOctagonalNumber(n: nat) returns (o: nat)
  requires n >= 0
  ensures o == n * (3 * n - 2)
{
  // Formula for the n-th octagonal number:
  // O_n = n(3n - 2)
  o := n * (3 * n - 2);
}

method CheckNthOctagonalNumber(n: nat) returns (o: nat)
  requires n >= 0
  ensures o == n * (3 * n - 2)
{
  // Compute using a loop (no recursion), summing the first n odd-like octagonal increments.
  // Recurrence:
  // O_0 = 0
  // O_k = O_(k-1) + (6k - 5), for k >= 1
  var k: nat := 0;
  o := 0;

  while k < n
    invariant 0 <= k <= n
    invariant o == k * (3 * k - 2)
    decreases n - k
  {
    k := k + 1;
    o := o + (6 * k - 5);
  }

  // Cross-check against the direct implementation.
  var direct := NthOctagonalNumber(n);
  assert o == direct;
}

method Main()
{
  // Basic sanity checks / edge cases
  var a := CheckNthOctagonalNumber(0);
  assert a == 0;

  var b := CheckNthOctagonalNumber(1);
  assert b == 1;

  var c := CheckNthOctagonalNumber(2);
  assert c == 8;

  var d := CheckNthOctagonalNumber(5);
  assert d == 65;
}
