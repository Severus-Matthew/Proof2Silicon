method Max(arr: array<int>) returns (m: int)
  requires arr != null
  requires arr.Length > 0
  ensures forall i :: 0 <= i < arr.Length ==> arr[i] <= m
  ensures exists i :: 0 <= i < arr.Length && arr[i] == m
{
  m := arr[0];
  var i := 1;

  while i < arr.Length
    invariant 1 <= i <= arr.Length
    invariant forall j :: 0 <= j < i ==> arr[j] <= m
    invariant exists j :: 0 <= j < i && arr[j] == m
    decreases arr.Length - i
  {
    if arr[i] > m {
      m := arr[i];
    }
    i := i + 1;
  }
}

method Main()
{
  var a := new int[5];
  a[0] := 3;
  a[1] := 1;
  a[2] := 7;
  a[3] := -2;
  a[4] := 5;

  var maximum := Max(a);

  print "The maximum value is: ", maximum, "\n";
}
