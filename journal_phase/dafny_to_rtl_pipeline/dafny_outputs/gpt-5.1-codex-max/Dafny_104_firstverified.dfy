method SumTo(n: int) returns (s: int)
  requires n >= 0
  ensures s == n * (n + 1) / 2
{
  s := 0;
  var i := 0;
  while i <= n
    invariant 0 <= i <= n + 1
    invariant s == i * (i - 1) / 2
    decreases n + 1 - i
  {
    s := s + i;
    i := i + 1;
  }
  // At loop exit, i == n + 1 and s == (n + 1) * n / 2 by the invariants
  assert i == n + 1;
}
