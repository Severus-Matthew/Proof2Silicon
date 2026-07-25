method SumToN(n: nat) returns (sum: nat)
  requires n >= 0
  ensures sum == n * (n + 1) / 2
{
  var i: nat := 0;
  sum := 0;
  while i < n
    invariant i <= n
    invariant sum == i * (i + 1) / 2
    decreases n - i
  {
    i := i + 1;
    sum := sum + i;
  }
}
