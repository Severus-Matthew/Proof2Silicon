method FindMax(arr: array<int>) returns (max: int)
  requires arr.Length > 0
  ensures exists i :: 0 <= i < arr.Length && arr[i] == max
  ensures forall i :: 0 <= i < arr.Length ==> arr[i] <= max
{
  max := arr[0];
  var index: int := 1;
  
  while index < arr.Length
    invariant 0 <= index <= arr.Length
    invariant exists i :: 0 <= i < index && arr[i] == max
    invariant forall i :: 0 <= i < index ==> arr[i] <= max
  {
    if arr[index] > max {
      max := arr[index];
    }
    index := index + 1;
  }
}

method TestFindMax() {
  var arr1 := new int[5];
  arr1[0] := 3; arr1[1] := 1; arr1[2] := 4; arr1[3] := 1; arr1[4] := 5;
  
  var max1 := FindMax(arr1);
  assert max1 == 5;
  
  var arr2 := new int[3];
  arr2[0] := -1; arr2[1] := -5; arr2[2] := -3;
  
  var max2 := FindMax(arr2);
  assert max2 == -1;
  
  var arr3 := new int[1];
  arr3[0] := 42;
  
  var max3 := FindMax(arr3);
  assert max3 == 42;
  
  print "All tests passed!\n";
}

method Main() {
  TestFindMax();
}