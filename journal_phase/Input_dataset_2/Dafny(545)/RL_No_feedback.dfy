// Helper function to compute GCD
function Gcd(a: int, b: int): int
  requires a >= 0 && b >= 0
  decreases a + b
{
  if b == 0 then a else Gcd(b, a % b)
}

// Helper function for absolute value
function abs(x: int): int
{
  if x >= 0 then x else -x
}

// Method to compute determinant using Gaussian elimination
method DeterminantOptimized(X: array2<int>, n: int) returns (det: int)
  requires n > 0
  requires X.Length0 == n && X.Length1 == n
{
  det := 1;
  
  // Handle 1x1 matrix case
  if n == 1 {
    det := X[0, 0];
    return;
  }
  
  // Create a mutable copy of the matrix
  var M := new int[n, n];
  for i := 0 to n - 1
    invariant 0 <= i <= n
  {
    for j := 0 to n - 1
      invariant 0 <= j <= n
    {
      M[i, j] := X[i, j];
    }
  }
  
  // Perform Gaussian elimination
  for i := 0 to n - 1
    invariant 0 <= i <= n
  {
    // Find pivot
    var pivot := i;
    for k := i + 1 to n - 1
      invariant i + 1 <= k <= n
    {
      if abs(M[k, i]) > abs(M[pivot, i]) {
        pivot := k;
      }
    }
    
    // Swap rows if necessary
    if pivot != i {
      for j := 0 to n - 1
        invariant 0 <= j <= n
      {
        var temp := M[i, j];
        M[i, j] := M[pivot, j];
        M[pivot, j] := temp;
      }
      det := -det; // Row swap changes sign of determinant
    }
    
    // Skip if pivot is zero
    if M[i, i] == 0 {
      det := 0;
      return;
    }
    
    // Eliminate below
    for k := i + 1 to n - 1
      invariant i + 1 <= k <= n
    {
      var factor := M[k, i] / M[i, i];
      for j := i to n - 1
        invariant i <= j <= n
      {
        M[k, j] := M[k, j] - factor * M[i, j];
      }
    }
  }
  
  // Compute determinant as product of diagonal elements
  det := M[0, 0];
  for i := 1 to n - 1
    invariant 1 <= i <= n
    invariant det == product of M[0..i-1, 0..i-1] diagonal elements
  {
    det := det * M[i, i];
  }
}