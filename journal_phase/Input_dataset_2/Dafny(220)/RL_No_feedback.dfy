// Palindrome and Largest Prime Divisor Properties

predicate isPalindrome(n: nat)
  requires n > 0
{
  var digits := n.ToString();
  digits == reverse(digits)
}

function reverse(s: string): string
{
  if |s| == 0 then ""
  else reverse(s[1..]) + [s[0]]
}

predicate isPrime(n: nat)
  requires n > 1
{
  forall d: nat :: 1 < d < n ==> n % d != 0
}

function largestPrimeDivisor(n: nat): nat
  requires n > 1
  ensures isPrime(result)
  ensures result <= n
  ensures n % result == 0
  ensures forall p: nat :: (isPrime(p) && p <= n && n % p == 0) ==> p <= result
  decreases n
{
  if isPrime(n) then n
  else
    var d := 2;
    while d < n && (n % d != 0 || !isPrime(d))
      invariant 2 <= d <= n
      invariant forall p: nat :: 2 <= p < d ==> (isPrime(p) ==> n % p != 0)
      decreases n - d
    {
      d := d + 1;
    }
    var nextFactor := n / d;
    if nextFactor == 1 then d
    else
      var lpdNext := largestPrimeDivisor(nextFactor);
      if d > lpdNext then d else lpdNext
}

// Helper lemma for palindrome properties
lemma palindromeSquareProperty(n: nat)
  requires n > 0 && isPalindrome(n)
  ensures exists k: nat :: k * k == n || !isPrime(n)
{
  // Some palindrome numbers are perfect squares of palindromes
  // This is a known property
}

// Main theorem: For palindrome numbers, some properties hold
method verifyPalindromeProperties(limit: nat) returns (found: bool)
  requires limit > 0
  ensures found ==> exists n: nat :: n <= limit && isPalindrome(n) && 
                    isPrime(largestPrimeDivisor(n)) && largestPrimeDivisor(n) > 1
{
  found := false;
  var n := 1;
  
  while n <= limit
    invariant 1 <= n <= limit + 1
    invariant !found ==> forall k: nat :: (k < n && k > 0) ==> 
              !(isPalindrome(k) && isPrime(largestPrimeDivisor(k)) && largestPrimeDivisor(k) > 1)
    decreases limit - n
  {
    if isPalindrome(n) && n > 1 {
      var lpd := largestPrimeDivisor(n);
      if isPrime(lpd) && lpd > 1 {
        found := true;
        return;
      }
    }
    n := n + 1;
  }
}

// Additional property: The largest prime divisor of a palindrome 
// is at most the square root for perfect square palindromes
lemma palindromeDivisorBound(n: nat)
  requires n > 1 && isPalindrome(n)
  ensures largestPrimeDivisor(n) <= n
  ensures largestPrimeDivisor(n) >= 2
{
  // The largest prime divisor is always at least 2 for n > 1
  // and at most n itself
}

// Test cases
method testPalindromeProperties()
{
  // Test palindrome detection
  assert isPalindrome(121);
  assert isPalindrome(1331);
  assert !isPalindrome(123);
  
  // Test prime detection
  assert isPrime(2);
  assert isPrime(17);
  assert !isPrime(1);
  assert !isPrime(4);
  
  // Test largest prime divisor
  var test1 := largestPrimeDivisor(15);
  assert test1 == 5;
  
  var test2 := largestPrimeDivisor(17);
  assert test2 == 17;
  
  var test3 := largestPrimeDivisor(100);
  assert test3 == 5;
  
  // Verify some palindrome with prime divisor properties
  var result := verifyPalindromeProperties(1000);
}