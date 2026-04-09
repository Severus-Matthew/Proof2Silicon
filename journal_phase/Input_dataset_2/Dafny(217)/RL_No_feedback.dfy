// A Dafny program demonstrating mathematical reasoning about divisibility and transitivity

// Define a divisibility predicate
predicate Divisible(x: int, y: int)
  requires y != 0
{
  exists k: int :: x == k * y
}

// Lemma showing reflexivity of divisibility (every number divides itself)
lemma DivisibleReflexive(x: int)
  requires x != 0
  ensures Divisible(x, x)
{
  // x = 1 * x, so x divides x
}

// Lemma showing transitivity of divisibility
lemma DivisibleTransitive(a: int, b: int, c: int)
  requires b != 0 && c != 0
  requires Divisible(a, b) && Divisible(b, c)
  ensures Divisible(a, c)
{
  // If a = k1 * b and b = k2 * c, then a = (k1 * k2) * c
}

// Lemma showing that 1 divides every non-zero integer
lemma OneDividesAll(x: int)
  requires x != 0
  ensures Divisible(x, 1)
{
  // x = x * 1, so 1 divides x
}

// Identity function that preserves divisibility properties
function IdentityPreservesDivisibility(x: int): int
  ensures x != 0 ==> Divisible(IdentityPreservesDivisibility(x), x)
  ensures x != 0 ==> Divisible(x, IdentityPreservesDivisibility(x))
{
  x  // The identity function preserves all properties
}

// A more complex example: checking if a number preserves divisibility through a computation
method CheckDivisibilityPreservation(a: int, b: int) returns (preserves: bool)
  requires b != 0
  requires Divisible(a, b)
  ensures preserves ==> Divisible(a + b, b)
{
  // a + b = (k + 1) * b where a = k * b
  preserves := true;
  
  // This assertion should hold due to the precondition
  assert Divisible(a + b, b);
}

// Lemma about the sum of divisible numbers
lemma SumDivisibility(a: int, b: int, d: int)
  requires d != 0
  requires Divisible(a, d) && Divisible(b, d)
  ensures Divisible(a + b, d)
{
  // If a = k1 * d and b = k2 * d, then a + b = (k1 + k2) * d
}

// Example with sequences to demonstrate transitive reasoning
function SeqAllDivisibleBy(s: seq<int>, d: int): bool
  requires d != 0
  decreases |s|
{
  if |s| == 0 then true
  else Divisible(s[0], d) && SeqAllDivisibleBy(s[1..], d)
}

lemma SeqDivisibilityTransitive(s: seq<int>, d1: int, d2: int)
  requires d1 != 0 && d2 != 0
  requires SeqAllDivisibleBy(s, d1)
  requires Divisible(d1, d2)
  ensures SeqAllDivisibleBy(s, d2)
  decreases |s|
{
  if |s| > 0 {
    // Use transitivity on the first element
    DivisibleTransitive(s[0], d1, d2);
    // Recursively prove for the rest
    SeqDivisibilityTransitive(s[1..], d1, d2);
  }
}

// Main method demonstrating the concepts
method Main() {
  // Test basic divisibility
  var x := 12;
  var y := 4;
  var z := 2;
  
  // Show that 12 is divisible by 4
  assert Divisible(x, y);  // 12 = 3 * 4
  
  // Show that 4 is divisible by 2  
  assert Divisible(y, z);  // 4 = 2 * 2
  
  // Use transitivity to show 12 is divisible by 2
  DivisibleTransitive(x, y, z);
  assert Divisible(x, z);  // 12 = 6 * 2
  
  // Test identity preservation
  var idResult := IdentityPreservesDivisibility(x);
  assert idResult == x;
  assert Divisible(idResult, x) && Divisible(x, idResult);
  
  // Test with sequences
  var seq := [6, 9, 12];
  var d1 := 3;
  var d2 := 1;
  
  // All elements are divisible by 3
  assert SeqAllDivisibleBy(seq, d1);
  
  // 3 is divisible by 1
  assert Divisible(d1, d2);
  
  // Therefore all elements are divisible by 1
  SeqDivisibilityTransitive(seq, d1, d2);
  assert SeqAllDivisibleBy(seq, d2);
  
  print "All divisibility properties verified!\n";
  
  // Keep the original examples from the previous code
  var maxVal := Max(5, 3);
  print "Max of 5 and 3 is: ", maxVal, "\n";
  
  var counter := new Counter.Init();
  counter.Increment();
  counter.Increment();
  var count := counter.GetCount();
  print "Counter value: ", count, "\n";
  
  var fact5 := Factorial(5);
  print "Factorial of 5 is: ", fact5, "\n";
}

// Original methods from previous code (kept for compatibility)
method Max(a: int, b: int) returns (m: int)
  requires a >= 0 && b >= 0
  ensures m >= a && m >= b
  ensures m == a || m == b
{
  if a >= b {
    m := a;
  } else {
    m := b;
  }
}

class Counter {
  var count: int
  
  constructor Init()
    ensures count == 0
  {
    count := 0;
  }
  
  method Increment()
    modifies this
    ensures count == old(count) + 1
  {
    count := count + 1;
  }
  
  method GetCount() returns (c: int)
    ensures c == count
  {
    c := count;
  }
}

function Factorial(n: int): int
  requires n >= 0
  ensures Factorial(n) >= 1
  decreases n
{
  if n == 0 then 1
  else n * Factorial(n - 1)
}

ghost function SeqSum(s: seq<int>): int
  decreases |s|
{
  if |s| == 0 then 0
  else s[0] + SeqSum(s[1..])
}

method SumArraySimple(a: array<int>) returns (sum: int)
  ensures sum == SeqSum(a[..])
{
  sum := 0;
  var i := 0;
  
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant sum == SeqSum(a[..i])
    decreases a.Length - i
  {
    sum := sum + a[i];
    i := i + 1;
  }
}