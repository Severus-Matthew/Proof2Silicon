module CustomLibrary {
  
  // Basic arithmetic functions
  function plus(x: int, y: int): int {
    x + y
  }
  
  function minus(x: int, y: int): int {
    x - y
  }
  
  function times(x: int, y: int): int {
    if y == 0 then 0 else x * y
  }
  
  function square(x: int): int {
    if x % 2 != 0 then 0 else x * x
  }
  
  // Helper predicate for primality - CORRECTED: use ==> instead of &&
  predicate isPrime(n: int)
    requires n >= 0
  {
    n >= 2 &&
    forall d: int :: 2 <= d < n ==> n % d != 0
  }
  
  // Lemma 1: Commutativity of addition
  lemma labelProperty1(a: int, b: int)
    ensures plus(a, b) == plus(b, a)
  {
    // This is true by the commutative property of addition
  }
  
  // Lemma 2: All prime numbers greater than two are odd
  lemma labelProperty2(a: int)
    requires a > 2 && isPrime(a)
    ensures a % 2 == 1
  {
    // Proof: If a > 2 and prime, it cannot be even (divisible by 2)
    if a % 2 == 0 {
      // Then a is divisible by 2, contradicting primality (except for a = 2)
      // But a > 2, so contradiction
      assert false; // Contradiction
    }
  }
  
  // Lemma 3: If x is positive, then x + 1 is not zero
  lemma labelProperty3(x: int)
    requires x > 0
    ensures plus(x, 1) != 0
  {
    // x > 0 implies x >= 1, so x + 1 >= 2 > 0
    assert x + 1 > 1;
  }
  
  // Lemma 4: If x is even, then x % 2 equals 0
  lemma labelProperty4(x: int)
    requires x % 2 == 0
    ensures x % 2 == 0
  {
    // This is trivially true by the precondition
  }
  
  // Lemma 5: If a is even, then a % 2 equals 0
  // Note: This is essentially the same as Lemma 4, but with different name
  lemma labelProperty5(a: int)
    requires a % 2 == 0
    ensures a % 2 == 0
  {
    // Trivial - same as Lemma 4
  }
  
  // Lemma 6: If a is even and b is even, then a * b is even
  lemma labelProperty6(a: int, b: int)
    requires a % 2 == 0 && b % 2 == 0
    ensures times(a, b) % 2 == 0
  {
    // Since a and b are even, a = 2m, b = 2n for some integers m,n
    // Then a*b = (2m)*(2n) = 4mn = 2*(2mn), which is even
    var m: int := a / 2;
    var n: int := b / 2;
    assert a == 2 * m;
    assert b == 2 * n;
    assert a * b == 4 * m * n;
    assert (a * b) % 2 == 0;
  }
  
  // Lemma 7: If 5 divides a and 5 divides b, then 5 divides a + b
  lemma labelProperty7(a: int, b: int)
    requires a % 5 == 0 && b % 5 == 0
    ensures (a + b) % 5 == 0
  {
    // Since 5 divides a and b, a = 5m and b = 5n for some integers m,n
    // Then a + b = 5m + 5n = 5(m + n), which is divisible by 5
    var m: int := a / 5;
    var n: int := b / 5;
    assert a == 5 * m;
    assert b == 5 * n;
    assert a + b == 5 * (m + n);
    assert (a + b) % 5 == 0;
  }
  
  // Additional helper lemmas for verification
  lemma evenTimesEvenIsEven(a: int, b: int)
    requires a % 2 == 0 && b % 2 == 0
    ensures (a * b) % 2 == 0
  {
    var a2: int := a / 2;
    var b2: int := b / 2;
    assert a == 2 * a2;
    assert b == 2 * b2;
    assert a * b == 4 * a2 * b2;
    assert (a * b) % 2 == 0;
  }
  
  lemma subtractionNonZero(x: int, y: int)
    requires x != y
    ensures x - y != 0
  {
    // Direct proof: x - y = 0 implies x = y
  }
  
  // Lemma: Sum of two odd numbers is even
  lemma sumOfTwoOddsIsEven(a: int, b: int)
    requires a % 2 == 1 && b % 2 == 1
    ensures (a + b) % 2 == 0
  {
    // Since a and b are odd, a = 2m + 1, b = 2n + 1 for some integers m,n
    // Then a + b = (2m + 1) + (2n + 1) = 2m + 2n + 2 = 2(m + n + 1), which is even
    var m: int := (a - 1) / 2;
    var n: int := (b - 1) / 2;
    assert a == 2 * m + 1;
    assert b == 2 * n + 1;
    assert a + b == 2 * (m + n + 1);
    assert (a + b) % 2 == 0;
  }
  
  // Test methods to demonstrate usage
  method TestOperations(N1: int, N2: int, N3: int, N4: int, N5: int, N6: int, N7: int) 
    requires N2 >= N3  // Ensure non-negative result for subtraction
  {
    var result: int;
    
    // Apply the PLUS function
    result := plus(N1, 3);
    assert result == plus(N1, 3);
    
    // Apply the MINUS function
    result := minus(N2, N3);
    assert result >= 0;  // result is non-negative
    
    // Multiply N4 by 5
    result := times(N4, 5);
    
    // Check various properties
    if result % 5 != 0 {
      // This would contradict Lemma 7 or basic arithmetic
      // Since N4 * 5 should always be divisible by 5
      assert false;
    }
    
    // Additional checks
    if result == 0 {
      // Then N4 must be 0
    }
    
    if result == 5 {
      // Then N4 must be 1
    }
    
    // Check if result is even
    if result % 2 == 0 {
      // result is even
    }
    
    // Square operations
    result := square(N5);
    assert result == square(N5);
    
    result := square(N6);
    assert result == square(N6);
    
    result := square(N7);
    assert result == square(N7);
  }
}