function SeqSumPrefix(s: seq<int>, n: nat): int
  requires n <= |s|
{
  if n == 0 then 0 else SeqSumPrefix(s, n - 1) + s[n - 1]
}

function SeqSum(s: seq<int>): int
{
  SeqSumPrefix(s, |s|)
}

method SumArray(a: array<int>) returns (sum: int)
  ensures sum == SeqSum(a[..])
{
  var i := 0;
  sum := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant sum == SeqSumPrefix(a[..], i)
    decreases a.Length - i
  {
    sum := sum + a[i];
    i := i + 1;
  }
  assert i == a.Length;
  assert sum == SeqSumPrefix(a[..], a.Length);
  assert SeqSumPrefix(a[..], a.Length) == SeqSum(a[..]);
}

method RollingMax(a: seq<int>) returns (r: seq<int>)
  requires |a| > 0
  ensures |r| == |a|
  ensures forall i :: 0 <= i < |a| ==> r[i] == SeqSumPrefix(a, i + 1)
{
  var i := 0;
  var acc := 0;
  r := [];
  while i < |a|
    invariant 0 <= i <= |a|
    invariant |r| == i
    invariant acc == SeqSumPrefix(a, i)
    invariant forall j :: 0 <= j < i ==> r[j] == SeqSumPrefix(a, j + 1)
    decreases |a| - i
  {
    acc := acc + a[i];
    r := r + [acc];
    i := i + 1;
  }
}
