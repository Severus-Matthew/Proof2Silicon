method BinarySearch(arr: array<int>, key: int) returns (index: int)
  requires arr != null
  ensures index == -1 || (0 <= index < arr.Length && arr[index] == key)
  ensures index != -1 ==> (forall i :: 0 <= i < arr.Length && arr[i] == key ==> i == index)
{
  var low := 0;
  var high := arr.Length - 1;
  index := -1;
  
  while low <= high
    invariant 0 <= low <= high + 1 <= arr.Length
    invariant high < arr.Length
    invariant index == -1 || (0 <= index < arr.Length && arr[index] == key)
    invariant forall i :: 0 <= i < arr.Length && arr[i] == key ==> low <= i <= high
  {
    var mid := (low + high) / 2;
    if arr[mid] == key {
      index := mid;
      return;
    } else if arr[mid] < key {
      low := mid + 1;
    } else {
      high := mid - 1;
    }
  }
}

method TestBinarySearch() {
  // Using array literal syntax with square brackets
  var arr1 := new int[5];
  arr1[0] := 1; arr1[1] := 3; arr1[2] := 5; arr1[3] := 7; arr1[4] := 9;
  var idx1 := BinarySearch(arr1, 5);
  assert idx1 == 2;
  
  var idx2 := BinarySearch(arr1, 4);
  assert idx2 == -1;
  
  // Empty array
  var arr2 := new int[0];
  var idx3 := BinarySearch(arr2, 1);
  assert idx3 == -1;
  
  // Single element array
  var arr3 := new int[1];
  arr3[0] := 42;
  var idx4 := BinarySearch(arr3, 42);
  assert idx4 == 0;
  
  var idx5 := BinarySearch(arr3, 43);
  assert idx5 == -1;
}