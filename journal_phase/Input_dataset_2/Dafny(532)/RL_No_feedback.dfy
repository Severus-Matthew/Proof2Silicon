method AdditiveFactorial(arr: array<int>) returns (result: array<int>)
  requires arr != null
  ensures result != null && result.Length == arr.Length
{
  result := new int[arr.Length];
  
  if arr.Length == 0 {
    return;
  }
  
  if arr.Length == 1 {
    result[0] := arr[0];
    return;
  }
  
  // Handle first element - sum of first two elements
  result[0] := arr[0] + arr[1];
  
  var i: int := 1;
  while i < arr.Length - 1
    invariant 1 <= i <= arr.Length - 1
    invariant forall k :: 0 <= k < i ==> 
      result[k] == (
        if k == 0 then arr[0] + arr[1]
        else arr[k] + (if arr[k-1] > arr[k+1] then arr[k-1] else arr[k+1])
      )
  {
    var left := arr[i-1];
    var right := arr[i+1];
    var maxNeighbor := if left > right then left else right;
    result[i] := arr[i] + maxNeighbor;
    i := i + 1;
  }
  
  // Handle last element
  if arr.Length > 1 {
    result[arr.Length - 1] := arr[arr.Length - 1] + arr[arr.Length - 2];
  }
}

// Helper method for bubble sort implementation
method bubbleSort(arr: array<int>) 
  requires arr != null
  ensures forall i, j :: 0 <= i < j < arr.Length ==> arr[i] <= arr[j]
{
  var n := arr.Length;
  var i: int := 0;
  
  while i < n
    invariant 0 <= i <= n
    invariant forall k, l :: 0 <= k < l < n && l >= n - i ==> arr[k] <= arr[l]
    decreases n - i
  {
    var j: int := 0;
    while j < n - i - 1
      invariant 0 <= j <= n - i - 1
      invariant forall k :: 0 <= k < j ==> arr[k] <= arr[k+1]
      decreases n - i - j - 1
    {
      if arr[j] > arr[j+1] {
        var temp := arr[j];
        arr[j] := arr[j+1];
        arr[j+1] := temp;
      }
      j := j + 1;
    }
    i := i + 1;
  }
}

// Alternative implementation of FInd method (partition)
method FInd(arr: array<int>, pivotIndex: int) returns (newPivotIndex: int)
  requires arr != null
  requires 0 <= pivotIndex < arr.Length
  ensures 0 <= newPivotIndex < arr.Length
  ensures forall i :: newPivotIndex < i < arr.Length ==> arr[i] >= arr[newPivotIndex]
  ensures forall i :: 0 <= i < newPivotIndex ==> arr[i] <= arr[newPivotIndex]
{
  var pivot := arr[pivotIndex];
  
  // Move pivot to beginning for easier partitioning
  arr[pivotIndex] := arr[0];
  arr[0] := pivot;
  
  var i: int := 1;
  var j: int := arr.Length - 1;
  
  while i <= j
    invariant 0 <= i <= arr.Length
    invariant -1 <= j < arr.Length
    invariant i <= j + 1
    invariant forall k :: 1 <= k < i ==> arr[k] <= pivot
    invariant forall k :: j < k < arr.Length ==> arr[k] >= pivot
  {
    if arr[i] <= pivot {
      i := i + 1;
    } else if arr[j] >= pivot {
      j := j - 1;
    } else {
      // Swap arr[i] and arr[j]
      var temp := arr[i];
      arr[i] := arr[j];
      arr[j] := temp;
      i := i + 1;
      j := j - 1;
    }
  }
  
  // Move pivot to its final position
  arr[0] := arr[i-1];
  arr[i-1] := pivot;
  newPivotIndex := i-1;
}

// erasort method (another partition implementation)
method erasort(arr: array<int>, a: int)
  requires arr != null
  requires 0 <= a < arr.Length
  ensures forall i :: 0 <= i < a ==> arr[i] <= arr[a]
  ensures forall i :: a < i < arr.Length ==> arr[i] >= arr[a]
{
  var pivot := arr[a];
  var pivotIndex := a;
  
  var i: int := 0;
  var j: int := arr.Length - 1;
  
  while i <= j
    invariant 0 <= i <= arr.Length
    invariant -1 <= j < arr.Length
    invariant i <= j + 1
    invariant forall k :: 0 <= k < i && k != pivotIndex ==> arr[k] <= pivot
    invariant forall k :: j < k < arr.Length && k != pivotIndex ==> arr[k] >= pivot
    invariant pivotIndex == a && arr[pivotIndex] == pivot
  {
    if i == pivotIndex {
      i := i + 1;
    } else if j == pivotIndex {
      j := j - 1;
    } else if arr[i] <= pivot {
      i := i + 1;
    } else if arr[j] >= pivot {
      j := j - 1;
    } else {
      var temp := arr[i];
      arr[i] := arr[j];
      arr[j] := temp;
      i := i + 1;
      j := j - 1;
    }
  }
  
  // Ensure pivot is in correct position
  if pivotIndex < i-1 {
    arr[pivotIndex] := arr[i-1];
    arr[i-1] := pivot;
  } else if pivotIndex > i-1 {
    arr[pivotIndex] := arr[i];
    arr[i] := pivot;
  }
}