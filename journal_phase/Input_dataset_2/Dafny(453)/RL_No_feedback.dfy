method Main() {
    // Test 1: Verify set membership for numbers 3 and 4 in set {0, 1, 2}
    var inverse: set<int> := {0, 1, 2};
    var testValues: seq<int> := [3, 4];
    
    print "Testing if set {0, 1, 2} contains 3 or 4:\n";
    
    var i: int := 0;
    var foundCount: int := 0;
    while i < |testValues|
        invariant 0 <= i <= |testValues|
        invariant 0 <= foundCount <= i
    {
        var target: int := testValues[i];
        var found: bool := target in inverse;
        
        if found {
            foundCount := foundCount + 1;
            print "  Found ", target, " in the set\n";
        } else {
            print "  ", target, " is not in the set\n";
        }
        
        i := i + 1;
    }
    
    print "  Total found: ", foundCount, " of ", |testValues|, " in the set\n";
    
    if foundCount < |testValues| {
        print "The set {0, 1, 2} is a proper subset of the test sequence\n";
    } else {
        print "The set {0, 1, 2} is equal to the test sequence\n";
    }
}