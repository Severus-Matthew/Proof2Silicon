function sumArrayContentsSegment(a: array<int>, lo: int, hi: int): int
  requires 0 <= lo <= hi <= a.Length
  reads a
  decreases hi - lo
{
  if lo == hi then 0
  else a[lo] + sumArrayContentsSegment(a, lo + 1, hi)
}

function sumArrayContents(a: array<int>): int
  reads a
{
  if a.Length == 0 then 0
  else sumArrayContentsSegment(a, 0, a.Length)
}

method SumArray(a: array<int>) returns (sum: int)
  ensures sum == sumArrayContents(a)
  ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[i])
{
  sum := 0;
  var index := 0;
  
  while index < a.Length
    invariant 0 <= index <= a.Length
    invariant sum == sumArrayContentsSegment(a, 0, index)
    decreases a.Length - index
  {
    sum := sum + a[index];
    index := index + 1;
  }
}