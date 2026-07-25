function Sum(a: array<int>, lo: int, hi: int): int
  requires a != null
  requires 0 <= lo <= hi <= a.Length
  reads a
{
  if lo == hi then 0 else Sum(a, lo, hi - 1) + a[hi - 1]
}

method SumArray(a: array<int>) returns (sum: int)
  requires a != null
  ensures sum == Sum(a, 0, a.Length)
{
  var i := 0;
  sum := 0;

  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant sum == Sum(a, 0, i)
    decreases a.Length - i
  {
    sum := sum + a[i];
    i := i + 1;
  }

  assert i == a.Length;
  assert sum == Sum(a, 0, a.Length);
}
