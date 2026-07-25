function Stairs(n: nat): nat
  requires n >= 1
{
  if n == 1 then 1
  else if n == 2 then 2
  else Stairs(n - 1) + Stairs(n - 2)
}

method ComputeStairs(n: nat) returns (result: nat)
  requires n >= 1
  ensures result == Stairs(n)
{
  if n == 1 {
    result := 1;
  } else if n == 2 {
    result := 2;
  } else {
    var a: nat := 1;
    var b: nat := 2;
    var i: int := 3;
    while i <= n
      invariant 3 <= i <= n + 1
      invariant a == Stairs(i - 2)
      invariant b == Stairs(i - 1)
      decreases n - i
    {
      var c: nat := a + b;
      a := b;
      b := c;
      i := i + 1;
    }
    result := b;
  }
}
