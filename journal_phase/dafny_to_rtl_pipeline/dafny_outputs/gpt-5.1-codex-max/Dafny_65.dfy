method ComputeTriple(x: int) returns (r: int, y: int)
  ensures r == 3 * x
  ensures y == 2 * x
  ensures r == y + x
{
  y := 2 * x;
  r := y + x;
}

method Main() {
  var r: int;
  var y: int;
  r, y := ComputeTriple(4);
  assert r == 12 && y == 8;
}
