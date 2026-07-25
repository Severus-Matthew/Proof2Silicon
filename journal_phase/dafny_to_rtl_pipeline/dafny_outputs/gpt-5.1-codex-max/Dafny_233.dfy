function Abs(i: int): int
  ensures Abs(i) == (if i >= 0 then i else -i)
{
  if i >= 0 then i else -i
}

function Max(a: int, b: int): int
  ensures Max(a, b) == (if a >= b then a else b)
{
  if a >= b then a else b
}

method TestingAbs()
{
  var x := Abs(5);
  assert x == 5;
  var y := Abs(-3);
  assert y == 3;
}

method TestingAbs2()
{
  assert Abs(0) == 0;
  assert Abs(-7) == 7;
  assert Abs(10) == 10;
}

method TestingMax()
{
  assert Max(5, 3) == 5;
  assert Max(3, 5) == 5;
  assert Max(10, 10) == 10;
}
