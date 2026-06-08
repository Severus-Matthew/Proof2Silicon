module PowerMod {
  // Function to compute 2^n mod m using recursion
  method PowerMod(n: nat, m: nat) returns (result: nat)
    requires m > 0
    decreases n
  {
    if n == 0 {
      result := 1 % m;
    } else {
      var prev := PowerMod(n - 1, m);
      // Compute 2 * prev mod m without overflow
      result := (2 * prev) % m;
    }
  }

  // Function to compute 3^n mod m using recursion
  method ThreePowerMod(n: nat, m: nat) returns (result: nat)
    requires m > 0
    decreases n
  {
    if n == 0 {
      result := 1 % m;
    } else {
      var prev := ThreePowerMod(n - 1, m);
      // Compute 3 * prev mod m without overflow
      result := (3 * prev) % m;
    }
  }

  // Helper method to demonstrate the modular power computations
  method DemonstrateModularPowers() {
    var n: nat := 5;
    var m: nat := 13;
    
    var power2 := PowerMod(n, m);
    var power3 := ThreePowerMod(n, m);
    
    print "2^", n, " mod ", m, " = ", power2, "\n";
    print "3^", n, " mod ", m, " = ", power3, "\n";
    
    // Verify some properties
    assert power2 < m;
    assert power3 < m;
  }

  // Alternative iterative implementation for comparison
  method PowerModIterative(n: nat, m: nat) returns (result: nat)
    requires m > 0
  {
    result := 1 % m;
    var i: nat := 0;
    
    while i < n
      invariant result < m
      invariant i <= n
      decreases n - i
    {
      result := (2 * result) % m;
      i := i + 1;
    }
  }

  // Method to compute 2^n directly (may overflow for large n)
  method ComputePowerDirect(n: nat) returns (result: nat)
    decreases n
  {
    if n == 0 {
      result := 1;
    } else {
      var prev := ComputePowerDirect(n - 1);
      // This may overflow for large n
      result := 2 * prev;
    }
  }

  // Method that demonstrates overflow handling
  method DemonstrateOverflow() {
    var small_n: nat := 10;
    var large_n: nat := 100;
    
    // This will work
    var small_result := ComputePowerDirect(small_n);
    print "2^", small_n, " = ", small_result, "\n";
    
    // For large_n, we use modular version to avoid overflow
    var m: nat := 1000000007; // A large prime modulus
    var mod_result := PowerMod(large_n, m);
    print "2^", large_n, " mod ", m, " = ", mod_result, "\n";
    
    // Verify properties
    assert mod_result < m;
  }

  // Test method to verify correctness
  method TestModularPowers() {
    var test_cases := [(2, 5, 7), (3, 4, 11), (5, 3, 13)];
    
    for test_case in test_cases {
      var (base, exp, mod) := test_case;
      var result: nat;
      
      if base == 2 {
        result := PowerMod(exp, mod);
      } else if base == 3 {
        result := ThreePowerMod(exp, mod);
      }
      
      print base, "^", exp, " mod ", mod, " = ", result, "\n";
      assert result < mod;
    }
  }
}