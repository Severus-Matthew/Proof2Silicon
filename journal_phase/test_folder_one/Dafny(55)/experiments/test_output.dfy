method ToArray<T>(xs: seq<T>) returns (a: array<T>)
  ensures a.Length == |xs|
  ensures forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
  ensures fresh(a)
{
  var xs_size := |xs|;
  a := new T[0]; // Initialize with an empty array
  a := new T[xs_size];
  var i := 0;
  while i < xs_size
    invariant 0 <= i <= xs_size
    invariant forall j :: 0 <= j < i ==> a[j] == xs[j]
  {
    a[i] := xs[i];
    i := i + 1;
  }
  return a;
}