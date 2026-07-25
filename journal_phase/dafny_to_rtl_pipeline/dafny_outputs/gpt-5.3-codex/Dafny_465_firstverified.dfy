method PrefixSums(a: array<int>) returns (p: array<int>)
  requires a != null
  ensures p != null && p.Length == a.Length
  ensures forall i :: 0 <= i < p.Length ==>
            p[i] == (if i == 0 then a[0] else p[i-1] + a[i])
{
  p := new int[a.Length];

  if a.Length == 0 {
    return;
  }

  var i := 0;
  var running := 0;

  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant p != null && p.Length == a.Length
    invariant running == (if i == 0 then 0 else p[i-1])
    invariant forall k :: 0 <= k < i ==>
              p[k] == (if k == 0 then a[0] else p[k-1] + a[k])
    decreases a.Length - i
  {
    running := running + a[i];
    p[i] := running;

    assert p[i] == (if i == 0 then a[0] else p[i-1] + a[i]);

    i := i + 1;
  }
}
