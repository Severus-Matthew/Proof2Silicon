// Helper function to check invariants without restrictions on sequence length
function AssertInvariants<T>(xs: seq<T>, arr: array<T>): bool
  requires arr != null
  requires arr.Length == |xs|
  ensures AssertInvariants(xs, arr) == (forall i :: 0 <= i < |xs| ==> arr[i] == xs[i])
{
  forall i :: 0 <= i < |xs| ==> arr[i] == xs[i]
}

// PairBundle function that returns the first and last elements as a pair
function PairBundle<T>(xs: seq<T>): (T, T)
  requires |xs| >= 2
{
  (xs[0], xs[|xs| - 1])
}

method ToArray<T(==)>(xs: seq<T>) returns (arr: array<T>)
  requires |xs| >= 2  // Precondition: at least two elements
  ensures arr.Length == |xs|
  ensures forall i :: 0 <= i < |xs| ==> arr[i] == xs[i]
  ensures AssertInvariants(xs, arr)  // Postcondition: invariant holds
{
  // Create array from sequence (no immediate reallocation)
  arr := new T[|xs|];
  
  // Copy elements from sequence to array
  var i := 0;
  while i < |xs|
    invariant 0 <= i <= |xs|
    invariant forall j :: 0 <= j < i ==> arr[j] == xs[j]
  {
    arr[i] := xs[i];
    i := i + 1;
  }
  
  // Verify array length matches sequence length
  assert arr.Length == |xs|;
  
  // Verify all elements were copied correctly
  assert forall j :: 0 <= j < |xs| ==> arr[j] == xs[j];
  
  // Check the invariant using the helper function
  assert AssertInvariants(xs, arr);
  
  // Verify PairBundle works correctly (optional check)
  var (first, last) := PairBundle(xs);
  assert first == xs[0];
  assert last == xs[|xs| - 1];
}

// Test method to verify correctness
method TestToArray() {
  // Test with integer sequence
  var seq1 := [1, 2, 3, 4, 5];
  var arr1 := ToArray(seq1);
  
  // Verify postconditions
  assert arr1.Length == 5;
  assert arr1[0] == 1 && arr1[4] == 5;
  assert AssertInvariants(seq1, arr1);
  
  // Test with string sequence  
  var seq2 := ["a", "b", "c"];
  var arr2 := ToArray(seq2);
  
  // Verify postconditions
  assert arr2.Length == 3;
  assert arr2[0] == "a" && arr2[2] == "c";
  assert AssertInvariants(seq2, arr2);
  
  // Test PairBundle function
  var (first, last) := PairBundle(seq1);
  assert first == 1 && last == 5;
  
  var (first2, last2) := PairBundle(seq2);
  assert first2 == "a" && last2 == "c";
}