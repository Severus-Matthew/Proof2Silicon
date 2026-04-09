method BinarySearch(a: array<int>, target: int) returns (index: int)
  requires forall i, j :: 0 <= i < j < a.Length ==> a[i] < a[j]  // Strictly sorted
  ensures 0 <= index < a.Length ==> a[index] == target
  ensures index < 0 ==> forall i :: 0 <= i < a.Length ==> a[i] != target
{
  var low := 0;
  var high := a.Length - 1;
  index := -1;  // Default value if target not found
  
  while low <= high
    invariant 0 <= low <= high + 1
    invariant high < a.Length
    invariant forall i :: 0 <= i < a.Length && !(low <= i <= high) ==> a[i] != target
  {
    var mid := low + (high - low) / 2;
    
    if a[mid] == target {
      index := mid;
      return;
    } else if a[mid] < target {
      low := mid + 1;
    } else {
      high := mid - 1;
    }
  }
}