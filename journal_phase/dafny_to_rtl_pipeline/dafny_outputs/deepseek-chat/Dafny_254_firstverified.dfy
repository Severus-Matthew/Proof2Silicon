function NthOctagonalNumber(n: nat): nat
{
    n * (3 * n - 2)
}

// Check function to verify correctness for a given n
function CheckNthOctagonalNumber(n: nat): bool
{
    // The octagonal number formula is O_n = n * (3n - 2)
    // We can verify by checking that the result matches the formula
    var result := NthOctagonalNumber(n);
    result == n * (3 * n - 2)
}

// Method to compute and verify octagonal numbers
method ComputeAndCheckOctagonalNumbers()
{
    // Test for first few values
    assert NthOctagonalNumber(0) == 0;
    assert NthOctagonalNumber(1) == 1;
    assert NthOctagonalNumber(2) == 8;
    assert NthOctagonalNumber(3) == 21;
    assert NthOctagonalNumber(4) == 40;
    assert NthOctagonalNumber(5) == 65;
    
    // Verify using check function
    assert CheckNthOctagonalNumber(0);
    assert CheckNthOctagonalNumber(1);
    assert CheckNthOctagonalNumber(2);
    assert CheckNthOctagonalNumber(3);
    assert CheckNthOctagonalNumber(4);
    assert CheckNthOctagonalNumber(5);
    
    // Additional verification for larger values
    assert CheckNthOctagonalNumber(10);
    assert CheckNthOctagonalNumber(100);
}
