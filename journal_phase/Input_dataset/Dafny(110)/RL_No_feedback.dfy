method Main() {
    var n: int := 5;  // Example input
    var result: int := factorial(n);
    
    print "Factorial of ", n, " is: ", result, "\n";
    
    // Assert that factorial is >= 1 for non-negative n
    assert n >= 0 ==> result >= 1;
}

function factorial(n: int): int
    requires n >= 0
    ensures factorial(n) >= 1
{
    if n == 0 then
        1
    else
        n * factorial(n - 1)
}

method ComputeFactorial(n: int) returns (result: int)
    requires n >= 0
    ensures result >= 1
    ensures result == factorial(n)
{
    result := 1;
    var i: int := 1;
    
    while i <= n
        invariant 1 <= i <= n + 1
        invariant result == factorial(i - 1)
    {
        result := result * i;
        i := i + 1;
    }
}

// Verification tests
method TestFactorial() {
    // Test base case
    assert factorial(0) == 1;
    
    // Test small values
    assert factorial(1) == 1;
    assert factorial(2) == 2;
    assert factorial(3) == 6;
    assert factorial(4) == 24;
    assert factorial(5) == 120;
    
    // Verify property: factorial(n) >= 1 for all n >= 0
    var n: int := 0;
    while n < 10
        invariant n >= 0
        invariant forall k: int :: 0 <= k < n ==> factorial(k) >= 1
    {
        assert factorial(n) >= 1;
        n := n + 1;
    }
}

// Helper lemma to prove factorial properties
lemma FactorialPositive(n: int)
    requires n >= 0
    ensures factorial(n) >= 1
{
    // This is automatically proven by Dafny from the function specification
}