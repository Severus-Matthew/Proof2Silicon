predicate Par(n: int)
{
  n % 2 == 0
}

method FazAlgo(a: int, b: int) returns (x: int, y: int)
  requires a >= 0 && b >= 0
  requires Par(a - b)
  ensures x == y
  ensures x + y == a + b
  ensures Par(x - y)
{
  x := a;
  y := b;

  while x != y
    invariant x >= 0 && y >= 0
    invariant x + y == a + b
    invariant Par(x - y)
    decreases if x > y then x - y else y - x
  {
    if x > y {
      x := x - 1;
      y := y + 1;
    } else {
      y := y - 1;
      x := x + 1;
    }
  }

  assert x == y;
  assert x + y == a + b;
  assert Par(x - y);
}
