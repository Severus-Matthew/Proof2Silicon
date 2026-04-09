method removeElement<T(==)>(arr: array<T>, val: T) returns (newLength: int)
  modifies arr
  ensures newLength <= arr.Length
  ensures forall i :: 0 <= i < newLength ==> arr[i] != val
  ensures forall i :: newLength <= i < arr.Length ==> arr[i] == old(arr[i])
  ensures multiset(arr[..]) == multiset(old(arr[..]))
{
  var i := 0;
  var j := 0;
  
  while j < arr.Length
    invariant 0 <= i <= j <= arr.Length
    invariant forall k :: 0 <= k < i ==> arr[k] != val
    invariant forall k :: i <= k < j ==> arr[k] == old(arr[k])
    invariant multiset(arr[..]) == multiset(old(arr[..]))
  {
    if arr[j] != val {
      if i != j {
        arr[i] := arr[j];
      }
      i := i + 1;
    }
    j := j + 1;
  }
  
  newLength := i;
}

// Test method to verify the implementation
method TestRemoveElement() {
  var arr := new int[5][1, 2, 3, 2, 4];
  var length := removeElement(arr, 2);
  
  assert length == 3;
  // The first 3 elements should not be 2
  assert arr[0] != 2;
  assert arr[1] != 2;
  assert arr[2] != 2;
  // The last 2 elements should be unchanged (but they're actually preserved from original)
  assert arr[3] == 2;
  assert arr[4] == 4;
  // Verify multiset preservation
  assert multiset(arr[..]) == multiset([1, 2, 3, 2, 4]);
}