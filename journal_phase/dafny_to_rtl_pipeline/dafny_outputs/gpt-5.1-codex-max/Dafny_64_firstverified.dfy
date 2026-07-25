module Triple {
  method triple(x: int) returns (r: int)
    ensures r == 3 * x
  {
    r := 3 * x;
  }
}
