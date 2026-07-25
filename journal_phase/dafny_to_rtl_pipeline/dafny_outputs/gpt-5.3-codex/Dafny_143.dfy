method add_small_numbers(a: array<int>, max: int, n: int)
  requires a != null
  requires 0 <= max
  requires 1 <= n
  modifies a
  ensures forall i :: 0 <= i < a.Length ==> a[i] <= max
  ensures forall i :: 0 <= i < a.Length ==> a[i] <= max * n
{
  var i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall k :: 0 <= k < i ==> a[k] <= max
    invariant forall k :: 0 <= k < i ==> a[k] <= max * n
    decreases a.Length - i
  {
    if a[i] > max {
      a[i] := max;
    }
    assert a[i] <= max;
    assert a[i] <= max * n;
    i := i + 1;
  }
}
