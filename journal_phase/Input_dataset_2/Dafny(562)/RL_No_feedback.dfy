function expo(x: int, n: nat): int
  decreases n
{
  if n == 0 then 1
  else x * expo(x, n - 1)
}

lemma ModProperty(k: nat)
  ensures expo(4, k) % 5 == expo(-1, k) % 5
  ensures expo(9, k) % 5 == expo(-1, k) % 5
  decreases k
{
  if k == 0 {
    // Base case
    assert expo(4, 0) == 1;
    assert expo(-1, 0) == 1;
    assert expo(9, 0) == 1;
  } else {
    ModProperty(k - 1);
    
    // For 4^k: 4 ≡ -1 (mod 5)
    assert expo(4, k) == 4 * expo(4, k - 1);
    calc {
      expo(4, k) % 5;
      == (4 * expo(4, k - 1)) % 5;
      == ((4 % 5) * (expo(4, k - 1) % 5)) % 5;
      == (4 * (expo(4, k - 1) % 5)) % 5;
      == (4 * (expo(-1, k - 1) % 5)) % 5;
      == (4 * expo(-1, k - 1)) % 5;
      == ((-1) * expo(-1, k - 1)) % 5;
      == expo(-1, k) % 5;
    }
    
    // For 9^k: 9 ≡ -1 (mod 5) since 9 % 5 = 4 and -1 % 5 = 4
    assert expo(9, k) == 9 * expo(9, k - 1);
    calc {
      expo(9, k) % 5;
      == (9 * expo(9, k - 1)) % 5;
      == ((9 % 5) * (expo(9, k - 1) % 5)) % 5;
      == (4 * (expo(9, k - 1) % 5)) % 5;
      == (4 * (expo(-1, k - 1) % 5)) % 5;
      == (4 * expo(-1, k - 1)) % 5;
      == ((-1) * expo(-1, k - 1)) % 5;
      == expo(-1, k) % 5;
    }
  }
}

// Final lemma that combines the two inductive proofs
lemma MainModProperty(k: nat)
  ensures expo(4, k) % 5 == expo(9, k) % 5
  decreases k
{
  ModProperty(k);
  // Both are congruent to expo(-1, k) modulo 5, so they're congruent to each other
}

lemma Expon23Even(k: nat)
  ensures (expo(2, 2*k) - expo(3, 2*k)) % 5 == 0
  decreases k
{
  if k == 0 {
    // Base case: 2^0 - 3^0 = 0
    assert expo(2, 0) == 1;
    assert expo(3, 0) == 1;
    assert (1 - 1) % 5 == 0;
  } else {
    Expon23Even(k - 1);
    
    // Show that 2^(2k) = 4^k and 3^(2k) = 9^k
    assert expo(2, 2*k) == expo(4, k);
    assert expo(3, 2*k) == expo(9, k);
    
    // Use modular properties
    ModProperty(k);
    
    // Since both are congruent to (-1)^k mod 5, their difference is 0 mod 5
    calc {
      (expo(2, 2*k) - expo(3, 2*k)) % 5;
      == (expo(4, k) - expo(9, k)) % 5;
      == (expo(-1, k) - expo(-1, k)) % 5;
      == 0 % 5;
      == 0;
    }
  }
}

method Main() {
  // Test expo function
  assert expo(2, 0) == 1;
  assert expo(2, 1) == 2;
  assert expo(2, 3) == 8;
  assert expo(3, 2) == 9;
  
  // Test the lemma for small even values
  var n: nat := 0;
  while n < 10
    invariant 0 <= n
  {
    if n % 2 == 0 {
      Expon23Even(n/2);
      assert (expo(2, n) - expo(3, n)) % 5 == 0;
    }
    n := n + 1;
  }
  
  // Test the new MainModProperty lemma
  var k: nat := 0;
  while k < 10
    invariant 0 <= k
  {
    MainModProperty(k);
    assert expo(4, k) % 5 == expo(9, k) % 5;
    k := k + 1;
  }
  
  print "All tests passed!\n";
}