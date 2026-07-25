method main(n: nat) returns (a: int, b: int)
  ensures a + b == 3 * n
{
  var i: nat := 0;
  a := 0;
  b := 0;

  while i < n
    invariant 0 <= i <= n
    invariant a == i
    invariant b == 2 * i
    invariant a + b == 3 * i
    decreases n - i
  {
    a := a + 1;
    b := b + 2;
    i := i + 1;
  }

  assert i == n;
  assert a + b == 3 * n;
}
