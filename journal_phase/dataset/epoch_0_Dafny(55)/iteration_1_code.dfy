method ToArray<T(==)>(xs: seq<T>) returns (arr: array<T>)
  requires |xs| >= 2  // Precondition: at least two elements
  ensures arr.Length == |xs|
  ensures forall i :: 0 <= i < |xs| ==> arr[i] == xs[i]
{
  // Create array from sequence
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
  
  // Check invariant before returning
  AssertInvariants(arr, xs);
}

function method AssertInvariants<T(==)>(arr: array<T>, xs: seq<T>): bool
  requires arr != null
  requires arr.Length == |xs|
  requires |xs| >= 2
  ensures AssertInvariants(arr, xs) == true
{
  // Check that array contains the same elements as sequence
  assert forall i :: 0 <= i < |xs| ==> arr[i] == xs[i];
  
  // Additional invariant check: first and last elements match PairBundle result
  var (first, last) := PairBundle(xs);
  assert arr[0] == first;
  assert arr[arr.Length - 1] == last;
  
  true
}

function method PairBundle<T>(xs: seq<T>): (T, T)
  requires |xs| >= 2
  ensures PairBundle(xs).0 == xs[0]
  ensures PairBundle(xs).1 == xs[|xs| - 1]
{
  (xs[0], xs[|xs| - 1])
}

// Example usage and test
method Test() {
  var seq1 := [1, 2, 3, 4, 5];
  var arr1 := ToArray(seq1);
  
  // Verify PairBundle works correctly
  var (first, last) := PairBundle(seq1);
  assert first == 1;
  assert last == 5;
  
  // Test with different sequence
  var seq2 := ["a", "b", "c"];
  var arr2 := ToArray(seq2);
  var (first2, last2) := PairBundle(seq2);
  assert first2 == "a";
  assert last2 == "c";
}