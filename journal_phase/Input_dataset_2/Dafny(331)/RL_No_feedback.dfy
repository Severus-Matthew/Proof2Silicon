module PrimeTester {
  // Function to check if a number is prime
  function isPrime(n: int): bool
    requires n >= 2
  {
    forall d: int :: 2 <= d < n ==> n % d != 0
  }
  
  // Method to verify if a number is prime
  method CheckPrime(n: int) returns (result: bool)
    requires n >= 2
    ensures result == isPrime(n)
  {
    var i := 2;
    result := true;
    
    while i < n
      invariant 2 <= i <= n
      invariant result == (forall d: int :: 2 <= d < i ==> n % d != 0)
      decreases n - i
    {
      if n % i == 0 {
        result := false;
        return;
      }
      i := i + 1;
    }
    // When the loop completes without finding a divisor, result remains true
  }
  
  // Main method to test some prime numbers
  method Main()
  {
    var test1: bool;
    var test2: bool;
    var test3: bool;
    var test4: bool;
    var test5: bool;
    var test6: bool;
    var test7: bool;
    
    // Test some known primes
    test1 := CheckPrime(2);
    print "2 is prime: ", test1, "\n";
    
    test2 := CheckPrime(3);
    print "3 is prime: ", test2, "\n";
    
    test3 := CheckPrime(17);
    print "17 is prime: ", test3, "\n";
    
    test4 := CheckPrime(19);
    print "19 is prime: ", test4, "\n";
    
    // Test a non-prime
    test5 := CheckPrime(15);
    print "15 is prime: ", test5, "\n";
    
    // Test another non-prime
    test6 := CheckPrime(25);
    print "25 is prime: ", test6, "\n";
    
    // Test edge case
    test7 := CheckPrime(2);
    print "2 is prime (again): ", test7, "\n";
  }
}