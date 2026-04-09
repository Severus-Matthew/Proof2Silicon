predicate isEven(n: nat)
{
  n % 2 == 0
}

function even(n: nat): bool
  decreases n
  ensures even(n) == isEven(n)
{
  if n == 0 then true
  else if n == 1 then false
  else even(n - 2)
}

lemma even_is_correct(n: nat)
  ensures even(n) == isEven(n)
  decreases n
{
  // Proof by induction
  if n == 0 {
    // Base case: 0 is even
    // Trivially true from function definition
  } else if n == 1 {
    // Base case: 1 is odd  
    // Trivially true from function definition
  } else {
    // Inductive step
    // Show that even(n) = even(n-2) and isEven(n) = isEven(n-2)
    even_is_correct(n - 2);
    // The function definition ensures even(n) = even(n-2)
    // And mathematically, n % 2 = (n-2) % 2 for n >= 2
    // This follows from: n % 2 = ((n-2) + 2) % 2 = (n-2) % 2
  }
}

method Main() {
  // Test cases with verification
  var n1 := 4;
  even_is_correct(n1);
  var r1 := even(n1);
  print "even(", n1, ") = ", r1, "\n";
  assert r1 == true;
  
  var n2 := 7;
  even_is_correct(n2);
  var r2 := even(n2);
  print "even(", n2, ") = ", r2, "\n";
  assert r2 == false;
  
  // Verify specific cases using the lemma
  even_is_correct(1);
  assert !even(1);
  
  even_is_correct(3);
  assert !even(3);
  
  even_is_correct(5);
  assert !even(5);
  
  even_is_correct(0);
  assert even(0);
  
  even_is_correct(2);
  assert even(2);
  
  even_is_correct(4);
  assert even(4);
  
  print "All tests passed!\n";
}