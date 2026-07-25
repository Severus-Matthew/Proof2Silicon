method Mult(x: nat, y: nat) returns (r: nat)
  ensures r == x * y
{
  var i: nat := 0;
  r := 0;

  while i < x
    invariant 0 <= i <= x
    invariant r == i * y
    decreases x - i
  {
    r := r + y;
    i := i + 1;
  }

  assert i == x;
  assert r == x * y;
}
