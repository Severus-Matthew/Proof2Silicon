module PrimeChecker {

  method IsPrime(n: int) returns (result: bool)
    requires n >= 2
    ensures result ==> forall k:int :: 2 <= k && k < n ==> n % k != 0
    ensures !result ==> exists k:int :: 2 <= k && k < n && n % k == 0
  {
    var k := 2;
    result := true;
    while k < n
      invariant 2 <= k <= n
      invariant result ==> forall j:int :: 2 <= j && j < k ==> n % j != 0
      decreases n - k
    {
      if n % k == 0 {
        // found a divisor
        assert 2 <= k && k < n && n % k == 0;
        result := false;
        // witness k for the existential
        assert exists j:int :: j == k && 2 <= j && j < n && n % j == 0;
        return;
      }
      k := k + 1;
    }
    // If we exit the loop, then k == n and no divisor was found
    assert k == n;
    assert forall j:int :: 2 <= j && j < k ==> n % j != 0;
    return;
  }

  method Main() {
    var n := 17;
    var isP := IsPrime(n);
    if isP {
      print n, " is prime.\n";
    } else {
      print n, " is not prime.\n";
    }
  }
}
