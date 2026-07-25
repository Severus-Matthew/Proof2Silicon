function SumPrefix(s: seq<int>, n: nat): int
  requires n <= |s|
{
  if n == 0 then 0 else SumPrefix(s, n - 1) + s[n - 1]
}

function SumArraySpec(s: seq<int>): int
{
  SumPrefix(s, |s|)
}

method SumArray(arr: array<int>) returns (s: int)
  requires arr != null
  ensures s == SumArraySpec(arr[..])
{
  var i: nat := 0;
  s := 0;

  while i < arr.Length
    invariant 0 <= i <= arr.Length
    invariant s == SumPrefix(arr[..], i)
    decreases arr.Length - i
  {
    assert i < arr.Length;
    assert arr[..][i] == arr[i];
    s := s + arr[i];
    i := i + 1;

    assert s == SumPrefix(arr[..], i);
  }

  assert i == arr.Length;
  assert s == SumPrefix(arr[..], arr.Length);
  assert s == SumArraySpec(arr[..]);
}
