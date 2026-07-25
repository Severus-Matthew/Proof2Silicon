method FillArray(a: array<int>, v: int)
  requires a != null
  modifies a
  ensures forall i :: 0 <= i < a.Length ==> a[i] == v
{
  var i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall j :: 0 <= j < i ==> a[j] == v
    decreases a.Length - i
  {
    a[i] := v;
    i := i + 1;
  }
}
