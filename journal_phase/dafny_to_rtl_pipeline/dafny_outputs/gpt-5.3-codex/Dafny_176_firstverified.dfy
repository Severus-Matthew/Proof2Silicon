method AbsIt(x: int) returns (y: int)
  ensures y >= 0
  ensures y == if x >= 0 then x else -x
{
  if x >= 0 {
    y := x;
  } else {
    y := -x;
  }
  assert y >= 0;
}
