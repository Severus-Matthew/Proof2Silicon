method Sum(n: nat) returns (s: nat)
  ensures s == n * (n + 1) / 2
{
  var i := 0;
  var acc := 0;
  while i < n
    invariant 0 <= i <= n
    invariant acc == i * (i + 1) / 2
    decreases n - i
  {
    i := i + 1;
    acc := acc + i;
  }
  s := acc;
}
