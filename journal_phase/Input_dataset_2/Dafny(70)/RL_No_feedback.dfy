method Tangent(x: array<int>, y: array<int>) returns (r: array<int>)
  requires y.Length > 1
  requires x.Length == y.Length
  requires forall i, j :: 0 <= i < j < x.Length ==> x[i] <= x[j]  // x must be sorted for binary search
  ensures r.Length == y.Length - 1
  ensures forall i :: 0 <= i < r.Length ==> r[i] == y[i] + y[i + 1]
  ensures r.Length > 0
  ensures 0 <= r[0] < x.Length
  ensures x[r[0]] == y[0]
{
  // First, find the index in x that equals y[0] using binary search
  var foundIndex := BinarySearch(x, y[0]);
  
  // We need to ensure we found the element
  assert foundIndex < x.Length;  // BinarySearch returns x.Length if not found
  assert x[foundIndex] == y[0];
  
  // Create result array
  r := new int[y.Length - 1];
  
  // Set first element to the found index
  r[0] := foundIndex;
  
  // Fill the rest with sums of consecutive y elements
  var i := 1;
  while i < r.Length
    invariant 1 <= i <= r.Length
    invariant r[0] == foundIndex
    invariant forall k :: 1 <= k < i ==> r[k] == y[k] + y[k + 1]
  {
    r[i] := y[i] + y[i + 1];
    i := i + 1;
  }
  
  // Verify postconditions
  assert 0 <= r[0] < x.Length;
  assert x[r[0]] == y[0];
}

// Helper method for binary search
method BinarySearch(arr: array<int>, key: int) returns (index: int)
  requires arr.Length > 0
  requires forall i, j :: 0 <= i < j < arr.Length ==> arr[i] <= arr[j]  // sorted
  ensures 0 <= index <= arr.Length
  ensures index < arr.Length ==> arr[index] == key
  ensures index == arr.Length ==> forall i :: 0 <= i < arr.Length ==> arr[i] != key
{
  var low := 0;
  var high := arr.Length;
  
  while low < high
    invariant 0 <= low <= high <= arr.Length
    invariant forall i :: 0 <= i < low ==> arr[i] < key
    invariant forall i :: high <= i < arr.Length ==> arr[i] > key
  {
    var mid := (low + high) / 2;
    if arr[mid] < key {
      low := mid + 1;
    } else if arr[mid] > key {
      high := mid;
    } else {
      return mid;
    }
  }
  
  return arr.Length;  // not found
}