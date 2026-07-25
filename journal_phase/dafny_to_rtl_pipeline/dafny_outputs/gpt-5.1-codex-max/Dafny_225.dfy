function sumSpec(f: nat -> nat, n: nat): nat
  decreases n
{
  if n == 0 then 0 else f(n) + sumSpec(f, n - 1)
}

method Sum(f: nat -> nat, n: nat) returns (res: nat)
  requires n >= 0
  ensures res == sumSpec(f, n)
{
  var s: nat := 0;
  var i: nat := 0;
  while i < n
    invariant 0 <= i <= n
    invariant s == sumSpec(f, i)
    decreases n - i
  {
    i := i + 1;
    s := s + f(i);
  }
  res := s;
}
