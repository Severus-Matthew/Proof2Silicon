// Function to compute the sum of first n elements in a sequence
function SumFirstN(s: seq<int>, n: int): int
  requires 0 <= n <= |s|
{
  if n == 0 then 0
  else s[n-1] + SumFirstN(s, n-1)
}

// Function to check if any prefix sum is negative
function HasNegativePrefix(s: seq<int>): bool
{
  if |s| == 0 then false
  else exists k :: 1 <= k <= |s| && SumFirstN(s, k) < 0
}

// Method to check for negative prefix sum using exists predicate
method CheckNegativePrefix(s: seq<int>) returns (hasNegative: bool)
  ensures hasNegative == HasNegativePrefix(s)
{
  // Directly use the function definition
  hasNegative := HasNegativePrefix(s);
}

// Alternative implementation with explicit exists check
method CheckNegativePrefixExplicit(s: seq<int>) returns (hasNegative: bool)
  ensures hasNegative == HasNegativePrefix(s)
{
  hasNegative := false;
  
  // Check if there exists any prefix with negative sum
  if |s| > 0 {
    var i := 1;
    while i <= |s|
      invariant 1 <= i <= |s| + 1
      invariant hasNegative == (exists k :: 1 <= k < i && SumFirstN(s, k) < 0)
    {
      if SumFirstN(s, i) < 0 {
        hasNegative := true;
        return;
      }
      i := i + 1;
    }
  }
}

// Example usage and verification
method Example() {
  var s1 := [1, 2, 3, 4];
  var s2 := [1, -2, 3, -4];
  var s3 := [-1, 2, 3];
  var s4 := [];
  
  var result1, result2, result3, result4: bool;
  
  result1 := CheckNegativePrefix(s1);
  result2 := CheckNegativePrefix(s2);
  result3 := CheckNegativePrefix(s3);
  result4 := CheckNegativePrefix(s4);
  
  // These assertions should hold
  assert !result1;  // No negative prefix
  assert result2;   // Has negative prefix (1 + (-2) = -1)
  assert result3;   // Has negative prefix (first element is -1)
  assert !result4;  // Empty sequence has no negative prefix
  
  // Verification using the explicit method
  var result1e := CheckNegativePrefixExplicit(s1);
  var result2e := CheckNegativePrefixExplicit(s2);
  var result3e := CheckNegativePrefixExplicit(s3);
  var result4e := CheckNegativePrefixExplicit(s4);
  
  assert result1 == result1e;
  assert result2 == result2e;
  assert result3 == result3e;
  assert result4 == result4e;
  
  // Verification using the function directly
  assert !HasNegativePrefix(s1);
  assert HasNegativePrefix(s2);
  assert HasNegativePrefix(s3);
  assert !HasNegativePrefix(s4);
}