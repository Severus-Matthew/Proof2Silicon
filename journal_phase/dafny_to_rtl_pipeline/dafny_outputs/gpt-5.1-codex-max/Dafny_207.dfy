method FindMax(arr: array<int>) returns (maxIndex: int)
  requires arr != null
  requires arr.Length > 0
  ensures 0 <= maxIndex < arr.Length
  ensures forall j :: 0 <= j < arr.Length ==> arr[maxIndex] >= arr[j]
  ensures exists j :: 0 <= j < arr.Length && arr[maxIndex] == arr[j]
{
  maxIndex := 0;
  var i := 1;
  while i < arr.Length
    invariant 1 <= i <= arr.Length
    invariant 0 <= maxIndex < i
    invariant forall k :: 0 <= k < i ==> arr[maxIndex] >= arr[k]
    decreases arr.Length - i
  {
    if arr[i] > arr[maxIndex] {
      maxIndex := i;
    }
    i := i + 1;
  }
}

method Main()
{
  var arr := new int[5];
  arr[0] := 1;
  arr[1] := 2;
  arr[2] := 3;
  arr[3] := 4;
  arr[4] := 5;

  var maxIndex := FindMax(arr);
  print "The index of the maximum element is: ";
  print maxIndex;
  print "\n";
}
