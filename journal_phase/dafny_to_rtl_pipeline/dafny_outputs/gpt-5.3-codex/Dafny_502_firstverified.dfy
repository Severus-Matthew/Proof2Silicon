method ArrayMap<T>(a: array<T>, f: T -> T)
  requires a != null
  modifies a
  ensures a != null && a.Length == old(a.Length)
  ensures forall i :: 0 <= i < a.Length ==> a[i] == f(old(a[i]))
{
  var i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall j :: 0 <= j < i ==> a[j] == f(old(a[j]))
    invariant forall j :: i <= j < a.Length ==> a[j] == old(a[j])
    decreases a.Length - i
  {
    a[i] := f(a[i]);
    i := i + 1;
  }
}
