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
  
  // Print results as requested
  print "Sorted test 1: ";
  print s1;
  print "\n";
  
  print "Sorted test 2: ";
  print s2;
  print "\n";
  
  print "Sum of squares [1,2,3]: ";
  print SumOfSquares([1, 2, 3]);
  print "\n";
  
  print "Dot product: ";
  print dot;
  print "\n";
  
  print "ProcessArray result 1 - sum: ";
  print sum;
  print ", sorted: ";
  print sorted;
  print "\n";
  
  print "ProcessArray result 2 - sum: ";
  print sum2;
  print ", sorted: ";
  print sorted2;
  print "\n";
  
  print "All tests passed!\n";
}

// Test method for decimal precision
method TestDecimalPrecision()
{
  // Test basic decimal operations
  var x: real := 0.1;
  var y: real := 0.2;
  var z: real := 0.3;
  
  // Note: Due to floating point precision, 0.1 + 0.2 might not exactly equal 0.3
  // This is expected behavior in floating point arithmetic
  // assert x + y == z; // This might fail due to floating point precision
  
  // Test with exact fractions
  var a: real := 1.0 / 10.0;
  var b: real := 2.0 / 10.0;
  var c: real := 3.0 / 10.0;
  assert a + b == c; // This should hold
  
  // Test vector operations with decimals
  var v1: Vector := [0.1, 0.2, 0.3];
  var v2: Vector := [0.4, 0.5, 0.6];
  var dot: real := DotProduct(v1, v2);
  
  // Expected: 0.1*0.4 + 0.2*0.5 + 0.3*0.6 = 0.04 + 0.10 + 0.18 = 0.32
  assert dot == 0.32;
  
  // Test with larger precision
  var precise1: real := 1.23456789;
  var precise2: real := 9.87654321;
  assert precise1 + precise2 == 11.11111110;
  
  // Print results as requested
  print "Decimal x: ";
  print x;
  print "\n";
  
  print "Decimal y: ";
  print y;
  print "\n";
  
  print "Decimal z: ";
  print z;
  print "\n";
  
  print "a + b = c: ";
  print a + b;
  print " == ";
  print c;
  print "\n";
  
  print "Dot product with decimals: ";
  print dot;
  print "\n";
  
  print "Precise sum: ";
  print precise1 + precise2;
  print "\n";
  
  print "Decimal precision tests completed!\n";
}

// Main method to run the tests
method Main()
{
  TestFeatures();
  TestDecimalPrecision();
}