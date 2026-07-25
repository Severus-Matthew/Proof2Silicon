method Max(a: array<int>) returns (m: int)
  requires a.Length > 0
  ensures forall i :: 0 <= i < a.Length ==> m >= a[i]
  ensures exists i :: 0 <= i < a.Length && a[i] == m
{
  m := a[0];
  var i := 1;

  while i < a.Length
    invariant 1 <= i <= a.Length
    invariant forall j :: 0 <= j < i ==> m >= a[j]
    invariant exists j :: 0 <= j < i && a[j] == m
    decreases a.Length - i
  {
    if a[i] > m {
      m := a[i];
    }
    i := i + 1;
  }
}

method Main()
{
  var arr := new int[5];
  arr[0] := 3;
  arr[1] := 17;
  arr[2] := 9;
  arr[3] := 17;
  arr[4] := -5;

  var maximum := Max(arr);

  // From the postcondition of Max, maximum is at least every array element.
  assert maximum >= arr[1]; // arr[1] == 17

  // All elements are no greater than 17.
  assert forall i :: 0 <= i < arr.Length ==> arr[i] <= 17;

  // From the postcondition of Max, there is a position k with arr[k] == maximum.
  var k :| 0 <= k < arr.Length && arr[k] == maximum;
  assert maximum == arr[k];
  assert arr[k] <= 17;

  assert maximum <= 17;

  assert maximum == 17;
}
