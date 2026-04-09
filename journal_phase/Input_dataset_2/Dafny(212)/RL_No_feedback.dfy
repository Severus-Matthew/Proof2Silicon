// A simple Dafny program with assertions
method Main() {
    var x: int := 5;
    var y: int := 3;
    
    // Basic arithmetic assertions
    assert x + y == 8;
    assert x - y == 2;
    assert x * y == 15;
    
    // Comparison assertions
    assert x > y;
    assert x >= y;
    assert y < x;
    assert y <= x;
    assert x != y;
    
    // Boolean logic assertions
    var b1: bool := true;
    var b2: bool := false;
    assert b1 && !b2;
    assert b1 || b2;
    
    // Array assertions
    var arr: array<int> := new int[3];
    arr[0] := 1;
    arr[1] := 2;
    arr[2] := 3;
    assert arr[0] == 1;
    assert arr[1] == 2;
    assert arr[2] == 3;
    assert arr.Length == 3;
    
    // Sequence assertions - FIXED SYNTAX
    var seq: seq<int> := [1, 2, 3, 4, 5];
    assert seq.Length == 5;  // Fixed: using .Length instead of |seq|
    assert seq[0] == 1;
    assert seq[4] == 5;
    
    // Set assertions
    var s: set<int> := {1, 2, 3, 4, 5};
    assert 3 in s;
    assert 6 !in s;
    assert |s| == 5;  // This is fine for sets
    
    // More complex assertions
    var sum: int := 0;
    for i := 0 to 4
        invariant sum == i * (i + 1) / 2
    {
        sum := sum + i;
    }
    assert sum == 10; // 0+1+2+3+4 = 10
    
    // Function with postcondition
    var result: int := AddNumbers(7, 8);
    assert result == 15;
    
    print "All assertions passed!\n";
}

// Helper function with specification
function AddNumbers(a: int, b: int): int
    ensures AddNumbers(a, b) == a + b
{
    a + b
}

// Another method demonstrating loop invariants
method SumFirstN(n: int) returns (sum: int)
    requires n >= 0
    ensures sum == n * (n + 1) / 2
{
    sum := 0;
    var i: int := 0;
    
    while i <= n
        invariant sum == i * (i + 1) / 2
        invariant i <= n + 1
    {
        sum := sum + i;
        i := i + 1;
    }
}