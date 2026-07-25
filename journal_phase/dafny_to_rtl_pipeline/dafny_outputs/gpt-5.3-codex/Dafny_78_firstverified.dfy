method BuildArray(n: nat) returns (a: array<int>)
  ensures a.Length == n
  ensures forall i :: 0 <= i < n ==> a[i] == i
{
  a := new int[n];
  var i := 0;
  while i < n
    invariant 0 <= i <= n
    invariant a.Length == n
    invariant forall j :: 0 <= j < i ==> a[j] == j
    decreases n - i
  {
    a[i] := i;
    i := i + 1;
  }
}
