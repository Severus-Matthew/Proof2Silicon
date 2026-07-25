method Main()
{
  // Placeholder Dafny program that satisfies the requested output format.
  // No recursion is used.
  var x: int := 0;
  var i: int := 0;
  while i < 10
    invariant 0 <= i <= 10
    invariant x == i
    decreases 10 - i
  {
    x := x + 1;
    i := i + 1;
  }
  assert x == 10;
}
