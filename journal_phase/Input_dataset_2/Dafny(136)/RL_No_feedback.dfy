// Helper function to calculate the sum of a sequence
function sum(seq: seq<int>): int
  decreases |seq|
{
  if |seq| == 0 then 0
  else seq[0] + sum(seq[1..])
}

// Simpler implementation of CumulativeSum
function CumulativeSum(a: array<int>, i: int): seq<int>
  requires a != null
  requires 0 <= i < a.Length
  ensures |CumulativeSum(a, i)| == a.Length
  ensures forall k :: 0 <= k <= i ==> CumulativeSum(a, i)[k] == sum(a[..(k+1)])
  ensures forall k :: i < k < a.Length ==> CumulativeSum(a, i)[k] == 0
{
  var result: seq<int> := [];
  var currentSum := 0;
  var idx := 0;
  
  while idx < a.Length
    invariant 0 <= idx <= a.Length
    invariant |result| == idx
    invariant forall k :: 0 <= k < idx ==> result[k] == (if k <= i then sum(a[..(k+1)]) else 0)
  {
    if idx <= i {
      currentSum := currentSum + a[idx];
      result := result + [currentSum];
    } else {
      result := result + [0];
    }
    idx := idx + 1;
  }
  
  result
}

// Example usage and verification
method TestCumulativeSum()
{
  var a := new int[5];
  a[0] := 1; a[1] := 2; a[2] := 3; a[3] := 4; a[4] := 5;
  
  var b := CumulativeSum(a, 2);
  
  // Verify the results
  assert b[0] == 1;
  assert b[1] == 3;
  assert b[2] == 6;
  assert b[3] == 0;
  assert b[4] == 0;
  
  print "Test passed!\n";
}