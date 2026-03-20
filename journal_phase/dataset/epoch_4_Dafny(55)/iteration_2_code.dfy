function method SeqToArray<T>(xs: seq<T>): (a: array<T>)
  ensures fresh(a)
  ensures a.Length == |xs|
  ensures forall i :: 0 <= i < a.Length ==> a[i] == xs[i]
{
  var a := new T[|xs|];
  var i := 0;
  while i < |xs|
    invariant 0 <= i <= |xs|
    invariant forall j :: 0 <= j < i ==> a[j] == xs[j]
  {
    a[i] := xs[i];
    i := i + 1;
  }
  a
}