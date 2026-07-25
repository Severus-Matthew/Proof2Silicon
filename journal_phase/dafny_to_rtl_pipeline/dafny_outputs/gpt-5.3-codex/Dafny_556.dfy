method SumArray(a: array<int>) returns (s: int)
  ensures s == SumRange(a, 0, a.Length)
{
  var i := 0;
  s := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant s == SumRange(a, 0, i)
    decreases a.Length - i
  {
    s := s + a[i];
    i := i + 1;
    assert s == SumRange(a, 0, i);
  }
}

function SumRange(a: array<int>, lo: int, hi: int): int
  requires 0 <= lo <= hi <= a.Length
  reads a
{
  if lo == hi then 0 else SumRange(a, lo, hi - 1) + a[hi - 1]
}
