method Max(arr: array<int>) returns (max: int)
  requires arr.Length > 0
  ensures forall k :: 0 <= k < arr.Length ==> arr[k] <= max
  ensures exists k :: 0 <= k < arr.Length && arr[k] == max
{
  max := arr[0];
  var i := 1;
  
  while i < arr.Length
    invariant 0 <= i <= arr.Length
    invariant forall k :: 0 <= k < i ==> arr[k] <= max
    invariant exists k :: 0 <= k < i && arr[k] == max
  {
    if arr[i] > max {
      max := arr[i];
    }
    i := i + 1;
  }
}

method Main() 
{
  var arr := new int[5];
  arr[0] := 3;
  arr[1] := 7;
  arr[2] := 2;
  arr[3] := 9;
  arr[4] := 1;
  
  var m := Max(arr);
  print "Maximum value: ", m, "\n";
  
  // To verify m == 9, we need to explicitly check all array elements
  assert arr[0] == 3;
  assert arr[1] == 7;
  assert arr[2] == 2;
  assert arr[3] == 9;
  assert arr[4] == 1;
  
  // Now we can assert that 9 is in the array and all elements are ≤ 9
  assert exists k :: 0 <= k < arr.Length && arr[k] == 9;
  assert forall k :: 0 <= k < arr.Length ==> arr[k] <= 9;
  
  // Therefore m must be 9
  assert m == 9;
}