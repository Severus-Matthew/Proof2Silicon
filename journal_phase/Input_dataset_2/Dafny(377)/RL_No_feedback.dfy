// Dafny program demonstrating various features from the fragments

// Predicate to check if a sequence is sorted
predicate Sorted(s: seq<int>)
{
  forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
}

// Function to compute sum of squares with termination measure
function SumOfSquares(s: seq<int>): int
  decreases |s|
{
  if |s| == 0 then 0
  else s[0] * s[0] + SumOfSquares(s[1..])
}

// Linear algebra: Vector operations
type Vector = seq<real>

function DotProduct(v1: Vector, v2: Vector): real
  requires |v1| == |v2|
  decreases |v1|
{
  if |v1| == 0 then 0.0
  else v1[0] * v2[0] + DotProduct(v1[1..], v2[1..])
}

// Helper function to convert array to sequence
function arrayToSeq(arr: array<int>): seq<int>
  reads arr
{
  var i: int := 0;
  var result: seq<int> := [];
  while i < arr.Length
    invariant 0 <= i <= arr.Length
    invariant |result| == i
    invariant forall k :: 0 <= k < i ==> result[k] == arr[k]
  {
    result := result + [arr[i]];
    i := i + 1;
  }
  result
}

// Method with verification for array manipulation
method ProcessArray(arr: array<int>) returns (sum: int, sorted: bool)
  ensures sum == SumOfSquares(arrayToSeq(arr))
  ensures sorted == Sorted(arrayToSeq(arr))
{
  sum := 0;
  sorted := true;
  
  var i := 0;
  var seqSoFar: seq<int> := [];
  
  while i < arr.Length
    invariant 0 <= i <= arr.Length
    invariant |seqSoFar| == i
    invariant forall k :: 0 <= k < i ==> seqSoFar[k] == arr[k]
    invariant sum == SumOfSquares(seqSoFar)
    invariant sorted == Sorted(seqSoFar)
  {
    sum := sum + arr[i] * arr[i];
    seqSoFar := seqSoFar + [arr[i]];
    
    if i > 0 && arr[i] < arr[i-1] {
      sorted := false;
    }
    
    i := i + 1;
  }
}

// Test method with assertions
method TestFeatures()
{
  // Test Sorted predicate
  var s1 := [1, 2, 3, 4, 5];
  assert Sorted(s1);
  
  var s2 := [5, 3, 1];
  assert !Sorted(s2) by {
    assert s2[0] == 5;
    assert s2[1] == 3;
    assert 5 > 3;
  }
  
  // Test SumOfSquares function
  assert SumOfSquares([1, 2, 3]) == 1 + 4 + 9;
  assert SumOfSquares([]) == 0;
  
  // Test vector operations
  var v1 := [1.0, 2.0, 3.0];
  var v2 := [4.0, 5.0, 6.0];
  var dot := DotProduct(v1, v2);
  assert dot == 32.0 by {
    calc {
      DotProduct(v1, v2);
      == 1.0*4.0 + 2.0*5.0 + 3.0*6.0;
      == 4.0 + 10.0 + 18.0;
      == 32.0;
    }
  }
  
  // Test ProcessArray method
  var arr := new int[3];
  arr[0] := 1; arr[1] := 2; arr[2] := 3;
  var sum, sorted := ProcessArray(arr);
  assert sum == 14;  // 1² + 2² + 3² = 1 + 4 + 9 = 14
  assert sorted == true;
  
  // Test with unsorted array
  var arr2 := new int[3];
  arr2[0] := 3; arr2[1] := 2; arr2[2] := 1;
  var sum2, sorted2 := ProcessArray(arr2);
  assert sum2 == 14;  // 3² + 2² + 1² = 9 + 4 + 1 = 14
  assert sorted2 == false;
  
  print "All tests passed!\n";
}

// Main method to run the tests
method Main()
{
  TestFeatures();
}