predicate Par(n: int)
{
  n % 2 == 0
}

method FazAlgo(a: int, b: int) returns (x: int, y: int)
  requires a >= b
  requires a >= 0 && b >= 0
  requires Par(a - b)
  ensures x == y
  ensures x >= 0 && y >= 0
  ensures x <= a && y == b
  ensures Par(x - y)
{
  x := a;
  y := b;
  while x != y
    invariant y == b
    invariant x >= y
    invariant Par(x - y)
    invariant x >= 0 && y >= 0
    decreases x - y
  {
    x := x - 2;
  }
}
