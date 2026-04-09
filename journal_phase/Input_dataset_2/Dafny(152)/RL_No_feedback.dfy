// A complete Dafny proof example: Fibonacci sequence properties

function fib(n: nat): nat
  decreases n
{
  if n == 0 then 0
  else if n == 1 then 1
  else fib(n-1) + fib(n-2)
}

// Lemma proving that fib(n) is non-decreasing for n >= 1
lemma FibMonotonic(n: nat)
  requires n >= 1
  ensures fib(n) >= fib(n-1)
  decreases n
{
  if n == 1 {
    // Base case: fib(1) = 1 >= 0 = fib(0)
  } else if n == 2 {
    // fib(2) = 1 >= 1 = fib(1)
  } else {
    // Inductive step
    FibMonotonic(n-1);
    FibMonotonic(n-2);
    // fib(n) = fib(n-1) + fib(n-2) >= fib(n-1) by non-negativity
  }
}

// Lemma proving a specific property: fib(n+2) = fib(n+1) + fib(n)
lemma FibRecurrence(n: nat)
  ensures fib(n+2) == fib(n+1) + fib(n)
{
  // This follows directly from the definition
}

// Lemma proving fib grows at least linearly from n=2 onward
lemma FibGrowth(n: nat)
  requires n >= 2
  ensures fib(n) >= n-1
  decreases n
{
  if n == 2 {
    // fib(2) = 1 >= 1 = 2-1
  } else if n == 3 {
    // fib(3) = 2 >= 2 = 3-1
  } else {
    // For n >= 4, use induction
    // First, establish that n-1 >= 2 and n-2 >= 2 for the recursive calls
    assert n-1 >= 2;
    assert n-2 >= 2;
    
    FibGrowth(n-1);
    FibGrowth(n-2);
    // By induction hypothesis:
    // fib(n-1) >= (n-1)-1 = n-2
    // fib(n-2) >= (n-2)-1 = n-3
    
    // Now: fib(n) = fib(n-1) + fib(n-2) >= (n-2) + (n-3) = 2n-5
    
    // We need to show: 2n-5 >= n-1
    // This simplifies to: n >= 4, which is true for n >= 4
    assert 2*n - 5 >= n - 1;  // This holds because n >= 4
    // So for n >= 4, fib(n) >= 2n-5 >= n-1
  }
}

// Method to demonstrate monotonicity using a loop
method DemonstrateMonotonicity(n: nat)
  requires n >= 1
{
  var i: nat := 1;
  
  while i < n
    invariant 1 <= i <= n
    invariant forall k: nat :: 1 <= k < i ==> fib(k) >= fib(k-1)
  {
    // Prove fib(i) >= fib(i-1) for current i
    FibMonotonic(i);
    
    // Update the invariant for the new i value
    i := i + 1;
    
    // After incrementing i, we need to show that the invariant still holds
    // The invariant only requires fib(k) >= fib(k-1) for k < i
    // Since we just proved it for the old i (which is now i-1),
    // and all previous k values were already in the invariant,
    // the invariant is maintained
  }
  
  // After the loop, we know that for all k from 1 to n-1, fib(k) >= fib(k-1)
}

// Main method demonstrating the use of the lemmas
method Main()
{
  // Test some concrete values
  var f0 := fib(0);
  var f1 := fib(1);
  var f2 := fib(2);
  var f3 := fib(3);
  var f4 := fib(4);
  var f5 := fib(5);
  
  // Verify basic properties
  assert f0 == 0;
  assert f1 == 1;
  assert f2 == 1;
  assert f3 == 2;
  assert f4 == 3;
  assert f5 == 5;
  
  // Use our lemmas
  FibMonotonic(3);
  assert fib(3) >= fib(2);  // 2 >= 1
  
  FibRecurrence(3);
  assert fib(5) == fib(4) + fib(3);  // 5 == 3 + 2
  
  // Test FibGrowth lemma
  FibGrowth(4);
  assert fib(4) >= 3;  // 3 >= 3
  FibGrowth(5);
  assert fib(5) >= 4;  // 5 >= 4
  
  // Additional checks mentioned in the error description
  assert fib(4) >= fib(3); // fib(4) >= fib(3) = fib(2)+fib(1)
  
  // Demonstrate monotonicity using a loop
  DemonstrateMonotonicity(10);
  
  print "Fibonacci values: ", f0, ", ", f1, ", ", f2, ", ", f3, ", ", f4, ", ", f5, "\n";
  print "Proofs completed successfully!\n";
}