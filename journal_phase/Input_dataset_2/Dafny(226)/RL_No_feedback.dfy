method IsPrime(n: nat) returns (isPrime: bool)
  ensures isPrime == (n >= 2 && forall k: nat :: 2 <= k < n ==> n % k != 0)
{
  if n < 2 {
    isPrime := false;
    return;
  }
  
  var i: nat := 2;
  while i < n
    invariant 2 <= i <= n
    invariant forall k: nat :: 2 <= k < i ==> n % k != 0
  {
    if n % i == 0 {
      isPrime := false;
      return;
    }
    i := i + 1;
  }
  
  isPrime := true;
}

lemma DivisibleImpliesSmallerDivisor(n: nat, i: nat, k: nat)
  requires n >= 2
  requires i >= 2
  requires i * i > n
  requires 2 <= k < n
  requires n % k == 0
  ensures exists d: nat :: 2 <= d < i && n % d == 0
{
  // If k divides n, then n/k also divides n
  var d := n / k;
  
  // Since k >= i > √n, then d = n/k <= n/i < i
  // So d would be a divisor < i
  if d >= 2 && d < i {
    // Found a divisor d < i
    assert n % d == 0;
  } else if d >= i {
    // This can't happen because:
    // k >= i and d >= i implies k*d >= i*i > n
    // But k*d = n (since n % k == 0 and d = n/k)
    // Contradiction
    assert false;
  }
}

method OptimizedIsPrime(n: nat) returns (isPrime: bool)
  ensures isPrime == (n >= 2 && forall k: nat :: 2 <= k < n ==> n % k != 0)
{
  if n < 2 {
    isPrime := false;
    return;
  }
  
  if n == 2 {
    isPrime := true;
    return;
  }
  
  if n % 2 == 0 {
    isPrime := false;
    return;
  }
  
  var i: nat := 3;
  while i * i <= n
    invariant 3 <= i <= n + 1
    invariant i % 2 == 1
    invariant forall k: nat :: 2 <= k < i ==> n % k != 0
  {
    if n % i == 0 {
      isPrime := false;
      return;
    }
    i := i + 2;
  }
  
  // At this point:
  // 1. n >= 3 and odd
  // 2. i * i > n (loop condition failed)
  // 3. For all k where 2 <= k < i, n % k != 0
  
  // We need to show: forall k: nat :: 2 <= k < n ==> n % k != 0
  // We already know this for k < i. For k >= i, we use the lemma.
  
  // Prove by contradiction: if there exists k >= i that divides n,
  // then there must exist d < i that divides n (contradicting invariant)
  assert forall k: nat | 2 <= k < n && n % k == 0 :: 
    exists d: nat :: 2 <= d < i && n % d == 0 by {
    forall k: nat | 2 <= k < n && n % k == 0 
      ensures exists d: nat :: 2 <= d < i && n % d == 0
    {
      DivisibleImpliesSmallerDivisor(n, i, k);
    }
  }
  
  // Since our invariant says no divisor exists < i, and any divisor >= i
  // would imply a divisor < i, there can be no divisors at all
  isPrime := true;
}

method Main() {
  var result: bool;
  
  result := IsPrime(0);
  print "IsPrime(0) = ", result, "\n";
  assert result == false;
  
  result := IsPrime(1);
  print "IsPrime(1) = ", result, "\n";
  assert result == false;
  
  result := IsPrime(2);
  print "IsPrime(2) = ", result, "\n";
  assert result == true;
  
  result := IsPrime(3);
  print "IsPrime(3) = ", result, "\n";
  assert result == true;
  
  result := IsPrime(4);
  print "IsPrime(4) = ", result, "\n";
  assert result == false;
  
  result := IsPrime(17);
  print "IsPrime(17) = ", result, "\n";
  assert result == true;
  
  // Test optimized version
  result := OptimizedIsPrime(17);
  print "OptimizedIsPrime(17) = ", result, "\n";
  assert result == true;
  
  // Additional test cases
  result := OptimizedIsPrime(15);
  print "OptimizedIsPrime(15) = ", result, "\n";
  assert result == false;
  
  result := OptimizedIsPrime(29);
  print "OptimizedIsPrime(29) = ", result, "\n";
  assert result == true;
  
  // More test cases to ensure correctness
  result := OptimizedIsPrime(2);
  print "OptimizedIsPrime(2) = ", result, "\n";
  assert result == true;
  
  result := OptimizedIsPrime(3);
  print "OptimizedIsPrime(3) = ", result, "\n";
  assert result == true;
  
  result := OptimizedIsPrime(4);
  print "OptimizedIsPrime(4) = ", result, "\n";
  assert result == false;
  
  result := OptimizedIsPrime(9);
  print "OptimizedIsPrime(9) = ", result, "\n";
  assert result == false;
  
  result := OptimizedIsPrime(25);
  print "OptimizedIsPrime(25) = ", result, "\n";
  assert result == false;
}