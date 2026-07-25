method ReverseArray(a: array<int>)
  requires a != null
  modifies a
  ensures a.Length == old(a.Length)
  ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[a.Length - 1 - i])
{
  var i := 0;
  var j := a.Length - 1;

  while i < j
    invariant 0 <= i <= a.Length
    invariant -1 <= j < a.Length
    invariant i + j == a.Length - 1
    invariant forall k :: 0 <= k < i ==> a[k] == old(a[a.Length - 1 - k])
    invariant forall k :: j < k < a.Length ==> a[k] == old(a[a.Length - 1 - k])
    invariant forall k :: i <= k <= j ==> a[k] == old(a[k])
    decreases j - i
  {
    var tmp := a[i];
    a[i] := a[j];
    a[j] := tmp;

    i := i + 1;
    j := j - 1;
  }
}
