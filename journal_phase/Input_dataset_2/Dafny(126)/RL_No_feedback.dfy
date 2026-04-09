module SequenceVerifier {
  
  // Function to check if all elements in a sequence are distinct
  function AreDistinct(s: seq<int>): bool
  {
    forall i, j :: 0 <= i < j < |s| ==> s[i] != s[j]
  }
  
  // Function to check if sequence s is a permutation of sequence t
  function IsPermutation(s: seq<int>, t: seq<int>): bool
    requires |s| == |t|
  {
    multiset(s) == multiset(t)
  }
  
  // Function to check if sequence s is a derangement of sequence t
  // A derangement is a permutation where no element appears in its original position
  function IsDerangement(s: seq<int>, t: seq<int>): bool
    requires |s| == |t|
  {
    IsPermutation(s, t) && 
    (forall i :: 0 <= i < |s| ==> s[i] != t[i])
  }
  
  // Verify function that checks multiple properties of a sequence
  // Returns a sequence of integers where:
  // 0 = property fails, 1 = property holds
  method verify(s: seq<int>, t: seq<int>) returns (result: seq<int>)
    requires |s| == |t|
  {
    var distinct_s := if AreDistinct(s) then 1 else 0;
    var distinct_t := if AreDistinct(t) then 1 else 0;
    var permutation := if IsPermutation(s, t) then 1 else 0;
    var derangement := if IsDerangement(s, t) then 1 else 0;
    
    result := [distinct_s, distinct_t, permutation, derangement];
  }
  
  // Test method that generates a sequence representing a permutation
  method test(original: seq<int>) returns (permuted: seq<int>)
    requires |original| > 0
    ensures |permuted| == |original|
    ensures IsPermutation(permuted, original)
  {
    // Simple implementation: reverse the sequence as a valid permutation
    permuted := [];
    var i := |original|;
    while i > 0
      invariant 0 <= i <= |original|
      invariant |permuted| == |original| - i
      invariant multiset(permuted) + multiset(original[0..i]) == multiset(original)
    {
      i := i - 1;
      permuted := permuted + [original[i]];
    }
  }
  
  // End method that processes a multiset range
  method end(input: seq<int>) returns (states: seq<int>)
    requires |input| > 0
  {
    // Process the input to create states representing the multiset
    // Each state is the count of occurrences of each value
    var max_val := 0;
    var i := 0;
    
    // Find maximum value in input
    while i < |input|
      invariant 0 <= i <= |input|
      invariant forall k :: 0 <= k < i ==> max_val >= input[k]
    {
      if input[i] > max_val {
        max_val := input[i];
      }
      i := i + 1;
    }
    
    // Create counts array and initialize all elements to 0
    var counts := new int[max_val + 1];
    var j := 0;
    while j < max_val + 1
      invariant 0 <= j <= max_val + 1
      invariant forall k :: 0 <= k < j ==> counts[k] == 0
    {
      counts[j] := 0;
      j := j + 1;
    }
    
    // Count occurrences of each value
    i := 0;
    while i < |input|
      invariant 0 <= i <= |input|
      invariant forall k :: 0 <= k < max_val + 1 ==> 0 <= counts[k] <= i
      invariant forall k :: 0 <= k < max_val + 1 ==> 
        counts[k] == multiset(input[0..i])[k]
    {
      counts[input[i]] := counts[input[i]] + 1;
      i := i + 1;
    }
    
    // Convert counts to sequence (only non-zero counts)
    states := [];
    j := 0;
    while j < max_val + 1
      invariant 0 <= j <= max_val + 1
      invariant |states| == j
      invariant forall k :: 0 <= k < j ==> states[k] == counts[k]
    {
      states := states + [counts[j]];
      j := j + 1;
    }
  }
  
  // Main method to demonstrate the functionality
  method Main() {
    var original := [1, 2, 3, 4];
    var permuted := test(original);
    var verification := verify(original, permuted);
    var states := end(original);
    
    print "Original: ", original, "\n";
    print "Permuted: ", permuted, "\n";
    print "Verification [distinct_s, distinct_t, permutation, derangement]: ", verification, "\n";
    print "States (counts): ", states, "\n";
  }
}