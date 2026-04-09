method BinarySearch(a: array<int>, target: int) returns (index: int)
  requires a.Length > 0
  requires forall i, j :: 0 <= i < j < a.Length ==> a[i] <= a[j]  // array is sorted in non-decreasing order
  ensures -1 <= index < a.Length
  ensures index >= 0 ==> a[index] == target
  ensures index == -1 ==> forall i :: 0 <= i < a.Length ==> a[i] != target
{
  var left := 0;
  var right := a.Length - 1;
  index := -1;  // Initialize to -1 (not found)
  
  while left <= right && index == -1
    invariant 0 <= left <= right + 1
    invariant right < a.Length
    invariant forall i :: 0 <= i < left ==> a[i] < target
    invariant forall i :: right < i < a.Length ==> a[i] > target
    invariant index == -1 || (0 <= index < a.Length && a[index] == target)
    decreases right - left
  {
    var mid := left + (right - left) / 2;  // Avoids potential overflow
    
    if a[mid] == target {
      index := mid;
    } else if a[mid] < target {
      left := mid + 1;
    } else {
      right := mid - 1;
    }
  }
  
  // If we exit the loop, either:
  // 1. index != -1: we found the target
  // 2. left > right: target was not found
  // In both cases, postconditions are satisfied
}