method Target_Flat<T>(xs: seq<T>) returns (a: array<T>)
  requires |xs| > 0
  ensures fresh(a)
  ensures a.Length == |xs|
  ensures forall i | 0 <= i < a.Length :: a[i] == xs[i]
  decreases |xs|
{
  a := new T[|xs|];
  var i := 0;
  while i < |xs|
    invariant 0 <= i <= |xs|
    invariant forall j | 0 <= j < i :: a[j] == xs[j]
  {
    a[i] := xs[i];
    i := i + 1;
  }
}