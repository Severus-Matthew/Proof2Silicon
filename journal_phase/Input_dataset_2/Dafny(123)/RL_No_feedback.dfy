function SumInts(n: int): int
  requires n >= 0
  ensures SumInts(n) == n * (n + 1) / 2
  ensures SumInts(n) >= 0
  decreases n
{
  if n == 0 then 0
  else n + SumInts(n - 1)
}

lemma SumIntsFormula(n: int)
  requires n >= 0
  ensures SumInts(n) == n * (n + 1) / 2
{
  if n != 0 {
    SumIntsFormula(n - 1);
  }
}

method SumIntsLoop(n: int) returns (sum: int)
  requires n >= 0
  ensures sum == SumInts(n)
  ensures sum == n * (n + 1) / 2
{
  sum := 0;
  var i := 0;
  
  while i <= n
    invariant 0 <= i <= n + 1
    invariant sum == (if i == 0 then 0 else SumInts(i - 1))
    decreases n - i
  {
    if i > 0 {
      assert sum == SumInts(i - 1);
    }
    sum := sum + i;
    i := i + 1;
  }
  
  // Apply the lemma to help verification
  SumIntsFormula(n);
}

method Main() {
  var n := 5;
  var result := SumIntsLoop(n);
  print "Sum of integers from 0 to ", n, " is: ", result, "\n";
  
  // Verify for a few values
  var r0 := SumIntsLoop(0);
  assert r0 == 0;
  
  var r1 := SumIntsLoop(1);
  assert r1 == 1;
  
  var r10 := SumIntsLoop(10);
  assert r10 == 55;
}