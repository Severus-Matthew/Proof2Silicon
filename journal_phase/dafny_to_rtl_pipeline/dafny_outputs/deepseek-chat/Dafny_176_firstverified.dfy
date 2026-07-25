function Abs(x: int): int
{
  if x < 0 then -x else x
}

method AbsIt(x: int) returns (r: int)
  ensures r == Abs(x)
{
  if x < 0 {
    r := -x;
  } else {
    r := x;
  }
}
