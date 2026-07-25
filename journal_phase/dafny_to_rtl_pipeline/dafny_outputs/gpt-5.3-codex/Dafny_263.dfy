function SumSeqPrefix(s: seq<int>, n: nat): int
  requires n <= |s|
{
  if n == 0 then 0 else SumSeqPrefix(s, n - 1) + s[n - 1]
}

function SumSeq(s: seq<int>): int
{
  SumSeqPrefix(s, |s|)
}

method SumArray(a: array<int>) returns (sum: int)
  ensures sum == SumSeq(a[..])
{
  var i := 0;
  sum := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant sum == SumSeqPrefix(a[..], i)
    decreases a.Length - i
  {
    sum := sum + a[i];
    i := i + 1;
  }
  assert i == a.Length;
  assert sum == SumSeqPrefix(a[..], a.Length);
  assert SumSeq(a[..]) == SumSeqPrefix(a[..], a.Length);
}

method ClosestSmaller(n: int) returns (m: int)
  requires n > 0
  ensures m == n - 1
{
  m := n - 1;
}
