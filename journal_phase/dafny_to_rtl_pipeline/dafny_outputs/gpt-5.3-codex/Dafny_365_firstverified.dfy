method FindEvenNumbers(a: array<int>) returns (evens: seq<int>)
  requires a != null
  ensures forall x :: x in evens ==> x % 2 == 0
  ensures forall i :: 0 <= i < a.Length && a[i] % 2 == 0 ==> a[i] in evens
{
  var i := 0;
  evens := [];

  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall x :: x in evens ==> x % 2 == 0
    invariant forall j :: 0 <= j < i && a[j] % 2 == 0 ==> a[j] in evens
    decreases a.Length - i
  {
    if a[i] % 2 == 0 {
      evens := evens + [a[i]];
      assert a[i] in evens;
    }
    i := i + 1;
  }
}
