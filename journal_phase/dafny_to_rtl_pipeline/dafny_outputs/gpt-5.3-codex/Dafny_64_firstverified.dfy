method Triple(x: int) returns (r: int)
  ensures r == 3 * x
{
  if x == 0 {
    r := 0;
    assert r == 3 * x;
  } else {
    r := x + 2 * x;
    assert r == 3 * x;
  }
}
