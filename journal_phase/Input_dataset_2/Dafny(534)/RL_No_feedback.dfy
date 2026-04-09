method FindMajorityCandidate<T(==)>(A: seq<T>) returns (majority: T)
  requires |A| > 0
  ensures (exists x :: x in A && count(A, x) > |A| / 2) ==> majority == x
  ensures forall x :: x in A && count(A, x) > |A| / 2 ==> majority == x
{
  var candidate: T := A[0];
  var count: int := 1;
  
  // First pass: Find potential majority candidate using Boyer-Moore algorithm
  for i := 1 to |A| - 1
    invariant 0 <= count <= i
    invariant forall x :: x in A[0..i] && x != candidate ==> 
              2 * count > i || count == 0
  {
    if A[i] == candidate {
      count := count + 1;
    } else {
      count := count - 1;
      if count == 0 {
        candidate := A[i];
        count := 1;
      }
    }
  }
  
  // Second pass: Verify the candidate
  var verifyCount: int := 0;
  for i := 0 to |A| - 1
    invariant verifyCount <= i
    invariant verifyCount == CountInPrefix(A, candidate, i)
  {
    if A[i] == candidate {
      verifyCount := verifyCount + 1;
    }
  }
  
  if verifyCount > |A| / 2 {
    majority := candidate;
  } else {
    // No majority exists, return default (first element)
    majority := A[0];
  }
}

// Helper function to count occurrences in a prefix
function CountInPrefix<T(==)>(A: seq<T>, x: T, n: int): int
  requires 0 <= n <= |A|
  decreases n
{
  if n == 0 then 0
  else (if A[n-1] == x then 1 else 0) + CountInPrefix(A, x, n-1)
}

// Helper function to count occurrences with termination metric
function count<T(==)>(A: seq<T>, x: T): int
  decreases |A|
{
  if |A| == 0 then 0
  else (if A[0] == x then 1 else 0) + count(A[1..], x)
}

// Test method to verify the algorithm
method TestMajority() {
  var votes := ["A", "B", "A", "B", "A", "A"];
  var majority := FindMajorityCandidate(votes);
  assert majority == "A";
  
  // Test with no majority
  var votes2 := ["A", "B", "A", "B", "C", "C"];
  var majority2 := FindMajorityCandidate(votes2);
  // No assertion since any return is valid when no majority exists
  
  // Test with clear majority
  var votes3 := ["A", "A", "A", "B", "B"];
  var majority3 := FindMajorityCandidate(votes3);
  assert majority3 == "A";
}