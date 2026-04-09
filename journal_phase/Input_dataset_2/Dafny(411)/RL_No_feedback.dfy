method MergeSort(a: array<int>)
  modifies a
  ensures sorted(a[..])
  ensures multiset(a[..]) == old(multiset(a[..]))
  decreases a.Length
{
  if a.Length > 1 {
    var mid := a.Length / 2;
    
    // Create temporary arrays for left and right halves
    var left := new int[mid];
    var right := new int[a.Length - mid];
    
    // Copy elements to left array
    var i := 0;
    while i < mid
      invariant 0 <= i <= mid
      invariant forall k :: 0 <= k < i ==> left[k] == a[k]
    {
      left[i] := a[i];
      i := i + 1;
    }
    
    // Copy elements to right array
    i := 0;
    while i < a.Length - mid
      invariant 0 <= i <= a.Length - mid
      invariant forall k :: 0 <= k < i ==> right[k] == a[mid + k]
    {
      right[i] := a[mid + i];
      i := i + 1;
    }
    
    // Recursively sort both halves
    MergeSort(left);
    MergeSort(right);
    
    // Merge the sorted halves back into the original array
    Merge(a, left, right);
  }
}

method Merge(a: array<int>, left: array<int>, right: array<int>)
  requires a.Length == left.Length + right.Length
  requires sorted(left[..]) && sorted(right[..])
  modifies a
  ensures sorted(a[..])
  ensures multiset(a[..]) == multiset(left[..]) + multiset(right[..])
{
  var i := 0;
  var j := 0;
  var k := 0;
  
  while k < a.Length
    invariant 0 <= i <= left.Length
    invariant 0 <= j <= right.Length
    invariant k == i + j
    invariant k <= a.Length
    invariant sorted(a[0..k])
    invariant multiset(a[0..k]) == multiset(left[0..i]) + multiset(right[0..j])
    invariant (i < left.Length ==> forall m :: 0 <= m < k ==> a[m] <= left[i])
    invariant (j < right.Length ==> forall m :: 0 <= m < k ==> a[m] <= right[j])
  {
    if i < left.Length && (j >= right.Length || left[i] <= right[j]) {
      a[k] := left[i];
      i := i + 1;
    } else {
      a[k] := right[j];
      j := j + 1;
    }
    k := k + 1;
  }
}

predicate sorted(s: seq<int>)
{
  forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
}

// Test method
method TestMergeSort()
{
  var arr := new int[10];
  arr[0] := 5; arr[1] := 2; arr[2] := 9; arr[3] := 1; arr[4] := 5;
  arr[5] := 6; arr[6] := 0; arr[7] := 3; arr[8] := 4; arr[9] := 7;
  
  var originalMultiset := multiset(arr[..]);
  
  MergeSort(arr);
  
  assert sorted(arr[..]);
  assert multiset(arr[..]) == originalMultiset;
  
  // Verify the array is sorted by checking adjacent elements
  var idx := 0;
  while idx < arr.Length - 1
    invariant 0 <= idx <= arr.Length - 1
    invariant forall j :: 0 <= j < idx ==> arr[j] <= arr[j + 1]
  {
    assert arr[idx] <= arr[idx + 1];
    idx := idx + 1;
  }
}