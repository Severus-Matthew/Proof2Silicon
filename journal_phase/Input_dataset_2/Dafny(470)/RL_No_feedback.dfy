function PowerSpec(x: nat, y: nat): nat
  decreases y
{
  if y == 0 then 1
  else x * PowerSpec(x, y - 1)
}

method SimplePower(x: nat, y: nat) returns (result: nat)
  requires y >= 0
  ensures result == PowerSpec(x, y)
{
  result := 1;
  var i: nat := 0;
  
  while i < y
    invariant result == PowerSpec(x, i)
    decreases y - i
  {
    result := result * x;
    i := i + 1;
  }
}