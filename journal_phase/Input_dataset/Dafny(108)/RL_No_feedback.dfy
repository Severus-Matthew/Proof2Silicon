module VectorSimilarity {
  
  // Define a vector as an array of real numbers
  type Vector = array<real>
  
  // Function to compute cosine similarity between two vectors
  // Cosine similarity = (A·B) / (||A|| * ||B||)
  function CosineSimilarity(a: Vector, b: Vector): real 
    requires a.Length > 0 && b.Length > 0
    requires a.Length == b.Length
    ensures -1.0 <= CosineSimilarity(a, b) <= 1.0
  {
    var dotProduct: real := 0.0;
    var normA: real := 0.0;
    var normB: real := 0.0;
    
    for i := 0 to a.Length - 1
      invariant dotProduct == sumDotProduct(a, b, i)
      invariant normA == sumSquares(a, i)
      invariant normB == sumSquares(b, i)
    {
      dotProduct := dotProduct + a[i] * b[i];
      normA := normA + a[i] * a[i];
      normB := normB + b[i] * b[i];
    }
    
    if normA == 0.0 || normB == 0.0 then 0.0
    else dotProduct / (sqrt(normA) * sqrt(normB))
  }
  
  // Helper functions for verification
  function sumDotProduct(a: Vector, b: Vector, n: int): real
    requires 0 <= n <= a.Length
    requires a.Length == b.Length
    decreases n
  {
    if n == 0 then 0.0
    else sumDotProduct(a, b, n-1) + a[n-1] * b[n-1]
  }
  
  function sumSquares(a: Vector, n: int): real
    requires 0 <= n <= a.Length
    decreases n
  {
    if n == 0 then 0.0
    else sumSquares(a, n-1) + a[n-1] * a[n-1]
  }
  
  // Main function: Compute pairwise similarities between all vectors
  // and store results in a flat vector
  method foo(vectors: array<Vector>) returns (similarities: array<real>)
    requires vectors.Length > 0
    requires forall i :: 0 <= i < vectors.Length ==> vectors[i].Length > 0
    requires forall i, j :: 0 <= i < vectors.Length && 0 <= j < vectors.Length ==> 
             vectors[i].Length == vectors[j].Length
    ensures similarities.Length == vectors.Length * vectors.Length
    ensures forall i, j :: 0 <= i < vectors.Length && 0 <= j < vectors.Length ==>
             -1.0 <= similarities[i * vectors.Length + j] <= 1.0
    ensures forall i :: 0 <= i < vectors.Length ==>
             similarities[i * vectors.Length + i] == 1.0  // Self-similarity
  {
    var n := vectors.Length;
    similarities := new real[n * n];
    
    var i := 0;
    while i < n
      invariant 0 <= i <= n
      invariant forall k, l :: 0 <= k < i && 0 <= l < n ==>
               -1.0 <= similarities[k * n + l] <= 1.0
      invariant forall k :: 0 <= k < i ==>
               similarities[k * n + k] == 1.0
    {
      var j := 0;
      while j < n
        invariant 0 <= j <= n
        invariant forall l :: 0 <= l < j ==>
                 -1.0 <= similarities[i * n + l] <= 1.0
        invariant if j > i then similarities[i * n + i] == 1.0
      {
        // Compute similarity between vectors[i] and vectors[j]
        var sim := CosineSimilarity(vectors[i], vectors[j]);
        
        // Store in the flat array (row-major order)
        similarities[i * n + j] := sim;
        
        // Ensure symmetry for verification
        if i != j {
          // This assertion helps the verifier understand the symmetry property
          assert CosineSimilarity(vectors[i], vectors[j]) == 
                 CosineSimilarity(vectors[j], vectors[i]);
        }
        
        j := j + 1;
      }
      i := i + 1;
    }
  }
  
  // Alternative: Function that ensures theta and phi remain positive
  // This addresses the requirement about keeping values positive
  method ComputePositiveSimilarity(theta: Vector, phi: Vector) returns (sim: real)
    requires theta.Length > 0 && phi.Length > 0
    requires theta.Length == phi.Length
    requires forall i :: 0 <= i < theta.Length ==> theta[i] >= 0.0
    requires forall i :: 0 <= i < phi.Length ==> phi[i] >= 0.0
    ensures 0.0 <= sim <= 1.0  // With non-negative vectors, cosine similarity is between 0 and 1
  {
    sim := CosineSimilarity(theta, phi);
    // With non-negative vectors, cosine similarity is non-negative
    assert sim >= 0.0;
  }
  
  // Test method with example vectors
  method TestSimilarity()
  {
    var v1: Vector := new real[3];
    v1[0] := 1.0; v1[1] := 0.0; v1[2] := 0.0;
    
    var v2: Vector := new real[3];
    v2[0] := 0.0; v2[1] := 1.0; v2[2] := 0.0;
    
    var v3: Vector := new real[3];
    v3[0] := 1.0; v3[1] := 1.0; v3[2] := 0.0;
    
    var vectors: array<Vector> := new Vector[3];
    vectors[0] := v1;
    vectors[1] := v2;
    vectors[2] := v3;
    
    var similarities := foo(vectors);
    
    // Verify some properties
    assert similarities[0] == 1.0;  // v1 with itself
    assert similarities[4] == 1.0;  // v2 with itself
    assert similarities[8] == 1.0;  // v3 with itself
    assert similarities[1] == 0.0;  // v1 with v2 (orthogonal)
    
    print "Test completed successfully\n";
  }
}