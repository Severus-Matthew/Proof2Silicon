function fact(n: nat): nat
  decreases n
{
  if n == 0 then 1 else n * fact(n - 1)
}

method Factorial(n: nat) returns (res: nat)
  ensures res == fact(n)
{
  var i: nat := 0;
  res := 1;
  while i < n
    invariant 0 <= i <= n
    invariant res == fact(i)
    decreases n - i
  {
    i := i + 1;
    res := res * i;
  }
}
