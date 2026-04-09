function factorial(n: int): int
  requires 0 <= n
  decreases n
{
  if n == 0 then 1 else n * factorial(n-1)
}

lemma FactorialLemma(k: int)
  requires 0 < k
  ensures factorial(k) == k * factorial(k-1)
{
  // This is trivially true from the definition of factorial
  // Dafny can prove this automatically
}

method DecreasingLoopExample() {
    var k := 10;
    var product := 1;
    
    while k > 0
        invariant 0 <= k <= 10
        invariant product * factorial(k) == factorial(10)
        decreases k
    {
        // Use the lemma to establish the factorial relationship
        FactorialLemma(k);
        
        // Now this should follow from the invariant and the lemma
        assert product * k * factorial(k-1) == factorial(10);
        
        product := product * k;
        k := k - 1;
        
        // The invariant should hold for the next iteration
        // We know: product_old * factorial(k_old) == factorial(10)
        // From lemma: factorial(k_old) == k_old * factorial(k_old-1)
        // So: product_old * k_old * factorial(k_old-1) == factorial(10)
        // After update: product_new = product_old * k_old, k_new = k_old - 1
        // So: product_new * factorial(k_new) == factorial(10)
    }
    
    assert product == 3628800; // 10!
    assert k == 0;
}