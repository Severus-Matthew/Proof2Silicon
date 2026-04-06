module DivMod {
  
  // Non-recursive division using subtraction
  function DivSub(a: int, b: int): (d: int)
    requires b > 0
    ensures d >= 0
    ensures d * b <= a < (d + 1) * b
  {
    var count := 0;
    var remaining := a;
    
    while remaining >= b
      invariant count >= 0
      invariant remaining >= 0
      invariant a == count * b + remaining
      decreases remaining
    {
      count := count + 1;
      remaining := remaining - b;
    }
    
    count
  }
  
  // Non-recursive modulo using subtraction
  function ModSub(a: int, b: int): (r: int)
    requires b > 0
    ensures 0 <= r < b
    ensures exists d :: d >= 0 && a == d * b + r
  {
    var remaining := a;
    
    while remaining >= b
      invariant remaining >= 0
      decreases remaining
    {
      remaining := remaining - b;
    }
    
    remaining
  }
  
  // Lemma to relate DivSub and ModSub
  lemma DivModRelation(a: int, b: int)
    requires b > 0
    ensures a == DivSub(a, b) * b + ModSub(a, b)
    ensures 0 <= ModSub(a, b) < b
  {
    // The postconditions of DivSub and ModSub already ensure this
  }
  
  // Test function with various cases
  method TestDivMod() 
  {
    // Test case 1: Simple division
    var d1 := DivSub(10, 3);
    var m1 := ModSub(10, 3);
    assert d1 == 3 by {
      calc {
        3 * 3;
        9;
      }
    }
    assert m1 == 1 by {
      calc {
        10 - 3 * 3;
        10 - 9;
        1;
      }
    }
    assert 10 == d1 * 3 + m1;
    assert 0 <= m1 < 3;
    
    // Test case 2: Exact division
    var d2 := DivSub(15, 5);
    var m2 := ModSub(15, 5);
    assert d2 == 3;
    assert m2 == 0;
    assert 15 == d2 * 5 + m2;
    
    // Test case 3: Division with remainder
    var d3 := DivSub(7, 2);
    var m3 := ModSub(7, 2);
    assert d3 == 3;
    assert m3 == 1;
    assert 7 == d3 * 2 + m3;
    
    // Test case 4: Large numbers
    var d4 := DivSub(100, 7);
    var m4 := ModSub(100, 7);
    assert d4 == 14;
    assert m4 == 2;
    assert 100 == d4 * 7 + m4;
    
    // Test case 5: a < b
    var d5 := DivSub(2, 5);
    var m5 := ModSub(2, 5);
    assert d5 == 0;
    assert m5 == 2;
    assert 2 == d5 * 5 + m5;
    
    // Test case 6: a = 0
    var d6 := DivSub(0, 5);
    var m6 := ModSub(0, 5);
    assert d6 == 0;
    assert m6 == 0;
    assert 0 == d6 * 5 + m6;
    
    // Verify the relationship between DivSub and ModSub
    assert DivSub(10, 3) * 3 + ModSub(10, 3) == 10;
    assert DivSub(15, 5) * 5 + ModSub(15, 5) == 15;
    assert DivSub(7, 2) * 2 + ModSub(7, 2) == 7;
    
    print "All tests passed!\n";
  }
  
  // Additional verification method
  method VerifyDivModProperties(a: int, b: int) 
    requires b > 0
    ensures DivSub(a, b) >= 0
    ensures 0 <= ModSub(a, b) < b
    ensures a == DivSub(a, b) * b + ModSub(a, b)
  {
    // The properties are already ensured by the function postconditions
  }
}

// Main method to run tests
method Main() {
  DivMod.TestDivMod();
  
  // Additional verification
  DivMod.VerifyDivModProperties(25, 4);
  var d := DivMod.DivSub(25, 4);
  var m := DivMod.ModSub(25, 4);
  print "25 divided by 4: quotient = ", d, ", remainder = ", m, "\n";
  assert d == 6;
  assert m == 1;
  assert 25 == d * 4 + m;
}