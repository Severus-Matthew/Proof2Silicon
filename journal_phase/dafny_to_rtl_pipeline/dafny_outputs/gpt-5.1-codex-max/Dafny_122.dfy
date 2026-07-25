method BinarySearch(arr: array<int>, key: int) returns (idx: int)
  requires arr != null
  requires forall i, j :: 0 <= i < j < arr.Length ==> arr[i] <= arr[j]
  ensures idx == -1 || (0 <= idx < arr.Length && arr[idx] == key)
  ensures idx == -1 ==> forall i :: 0 <= i < arr.Length ==> arr[i] != key
{
  var low := 0;
  var high := arr.Length - 1;

  while low <= high
    invariant 0 <= low <= arr.Length
    invariant -1 <= high < arr.Length
    invariant low <= high + 1
    invariant forall i :: 0 <= i < low ==> arr[i] < key
    invariant forall i :: high + 1 <= i < arr.Length ==> arr[i] > key
    decreases high - low + 1
  {
    var mid := low + (high - low) / 2;
    assert low <= mid <= high;

    if arr[mid] == key {
      idx := mid;
      return;
    } else if arr[mid] < key {
      // Discard the left half including mid
      low := mid + 1;
    } else {
      // Discard the right half including mid
      high := mid - 1;
    }
  }

  // At this point, low == high + 1 and the key is not present
  assert forall i :: 0 <= i < arr.Length ==> arr[i] != key;
  idx := -1;
}

method Main()
{
  var a := new int[5];
  a[0] := 1;
  a[1] := 3;
  a[2] := 5;
  a[3] := 7;
  a[4] := 9;

  var i1 := BinarySearch(a, 7);
  assert 0 <= 3 < a.Length && a[3] == 7;
  assert exists k :: 0 <= k < a.Length && a[k] == 7;
  assert i1 != -1;
  assert 0 <= i1 < a.Length;
  assert a[i1] == 7;

  var i2 := BinarySearch(a, 2);
  assert i2 == -1 || (0 <= i2 < a.Length && a[i2] == 2);
}
