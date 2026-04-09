// Helper predicates for even/odd properties
predicate isEven(n: int)
  requires n >= 0
{
  n % 2 == 0
}

predicate isOdd(n: int)
  requires n >= 0
{
  n % 2 == 1
}

// Helper function to calculate sum of a sequence
function sum(s: seq<int>): int
  decreases |s|
{
  if |s| == 0 then 0
  else s[0] + sum(s[1..])
}

// Helper function to calculate product of two numbers
function product(a: int, b: int): int
{
  a * b
}

// Lemma to prove that if an index is even, it remains even
lemma EvenIndexLemma(index: int)
  requires index >= 0 && isEven(index)
  ensures isEven(index)
{
  // Trivial - precondition guarantees property
}

// Lemma to prove that if an index is odd, it remains odd
lemma OddIndexLemma(index: int)
  requires index >= 0 && isOdd(index)
  ensures isOdd(index)
{
  // Trivial - precondition guarantees property
}

// Lemma to prove that the sum of non-negative numbers is non-negative
lemma SumNonNegative(indices: seq<int>)
  requires forall i :: 0 <= i < |indices| ==> indices[i] >= 0
  ensures sum(indices) >= 0
{
  // The sum of non-negative numbers is non-negative
  if |indices| == 0 {
    // sum is 0, which is >= 0
  } else if |indices| == 1 {
    assert indices[0] >= 0 ==> sum(indices) >= 0;
  } else {
    var tail := indices[1..];
    SumNonNegative(tail);
    assert sum(indices) == indices[0] + sum(tail);
    assert indices[0] >= 0 && sum(tail) >= 0 ==> sum(indices) >= 0;
  }
}

// Lemma to prove that if both numbers are even, their product is non-negative
lemma ProductEvenLemma(a: int, b: int)
  requires a >= 0 && b >= 0 && isEven(a) && isEven(b)
  ensures a * b >= 0
{
  // Product of non-negative numbers is non-negative
}

// Lemma to prove that if both numbers are odd, their product is non-negative
lemma ProductOddLemma(a: int, b: int)
  requires a >= 0 && b >= 0 && isOdd(a) && isOdd(b)
  ensures a * b >= 0
{
  // Product of non-negative numbers is non-negative
}

// Main method to find the first even and odd indices and calculate their product
method MainMethod(indices: seq<int>) returns (result: int)
  requires |indices| > 0
  requires forall i :: 0 <= i < |indices| ==> indices[i] >= 0
  ensures result >= 0
{
  // Calculate the sum of all elements in indices
  var sumOfIndices := sum(indices);
  
  // Ensure the sum is non-negative (which it always is due to preconditions)
  SumNonNegative(indices);
  assert sumOfIndices >= 0;
  
  // Check if sum is positive
  if sumOfIndices > 0 {
    // Find first even index
    var firstEvenIndex := -1;
    var idx := 0;
    
    while idx < |indices| && firstEvenIndex == -1
      invariant 0 <= idx <= |indices|
      invariant firstEvenIndex == -1 || (0 <= firstEvenIndex < |indices| && isEven(indices[firstEvenIndex]))
      invariant forall j :: 0 <= j < idx ==> !isEven(indices[j]) || firstEvenIndex != -1
    {
      if isEven(indices[idx]) {
        firstEvenIndex := idx;
      }
      idx := idx + 1;
    }
    
    // Find first odd index
    var firstOddIndex := -1;
    idx := 0;
    
    while idx < |indices| && firstOddIndex == -1
      invariant 0 <= idx <= |indices|
      invariant firstOddIndex == -1 || (0 <= firstOddIndex < |indices| && isOdd(indices[firstOddIndex]))
      invariant forall j :: 0 <= j < idx ==> !isOdd(indices[j]) || firstOddIndex != -1
    {
      if isOdd(indices[idx]) {
        firstOddIndex := idx;
      }
      idx := idx + 1;
    }
    
    // Check if we found both an even and odd element
    if firstEvenIndex != -1 && firstOddIndex != -1 {
      // Verify properties
      EvenIndexLemma(indices[firstEvenIndex]);
      OddIndexLemma(indices[firstOddIndex]);
      
      // Calculate the product
      result := product(indices[firstEvenIndex], indices[firstOddIndex]);
      
      // The product is non-negative since both numbers are non-negative
      assert result >= 0;
    } else {
      // Handle case where we don't have both even and odd elements
      result := 0;
    }
  } else {
    // Handle case where sum is not positive
    result := 0;
  }
  
  // Verify that result is non-negative
  assert result >= 0;
}

// Test method to demonstrate the verification
method TestMainMethod()
{
  // Test case 1: Mixed even and odd indices
  var test1 := [1, 2, 3, 4, 5];
  var result1 := MainMethod(test1);
  assert result1 >= 0;
  
  // Test case 2: All even indices
  var test2 := [2, 4, 6, 8];
  var result2 := MainMethod(test2);
  assert result2 >= 0;
  
  // Test case 3: All odd indices
  var test3 := [1, 3, 5, 7];
  var result3 := MainMethod(test3);
  assert result3 >= 0;
  
  // Test case 4: With zeros
  var test4 := [0, 1, 2, 3];
  var result4 := MainMethod(test4);
  assert result4 >= 0;
}

// Additional helper method to generate test sequences
method GenerateTestSequence(start: int, count: int) returns (seq: seq<int>)
  requires start >= 0 && count >= 0
  ensures |seq| == count
  ensures forall i :: 0 <= i < count ==> seq[i] == start + i
{
  seq := [];
  var current := start;
  var i := 0;
  
  while i < count
    invariant |seq| == i
    invariant forall j :: 0 <= j < i ==> seq[j] == start + j
    invariant current == start + i
    invariant i <= count
  {
    seq := seq + [current];
    current := current + 1;
    i := i + 1;
  }
}