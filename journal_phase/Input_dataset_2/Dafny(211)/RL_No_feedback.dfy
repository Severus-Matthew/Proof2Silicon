method AssertionExample(n: nat) returns (result: nat)
  requires n >= 0
  ensures result == n * (n + 1) / 2
  decreases n
{
  result := 0;
  var i := 0;
  
  while i <= n
    invariant 0 <= i <= n + 1
    invariant result == (i - 1) * i / 2
    decreases n - i
  {
    // Assertion to help verification
    assert result == (i - 1) * i / 2;
    
    result := result + i;
    i := i + 1;
    
    // Another assertion to maintain the invariant
    assert result == (i - 1) * i / 2;
  }
  
  // Final assertion to ensure postcondition
  assert result == n * (n + 1) / 2;
}

method RecursiveExample(n: nat) returns (result: nat)
  requires n >= 0
  ensures result == n * (n + 1) / 2
  decreases n
{
  if n == 0 {
    result := 0;
  } else {
    var recursiveResult := RecursiveExample(n - 1);
    result := recursiveResult + n;
  }
}

method ArrayExample(a: array<int>) 
  requires a.Length > 0
  ensures forall k :: 0 <= k < a.Length ==> a[k] >= old(a[k])
{
  var i := 0;
  ghost var oldA := a[..];
  
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall k :: 0 <= k < i ==> a[k] >= oldA[k]
    decreases a.Length - i
  {
    // Assertion about array bounds
    assert 0 <= i < a.Length;
    
    if a[i] < 0 {
      a[i] := 0;
    }
    
    // Assertion to help maintain invariant
    assert forall k :: 0 <= k < i + 1 ==> a[k] >= oldA[k];
    
    i := i + 1;
  }
  
  // Final assertion to ensure postcondition
  assert forall k :: 0 <= k < a.Length ==> a[k] >= oldA[k];
}

function VerificationHelper(x: int, y: int) : int
  requires x >= 0 && y >= 0
  ensures VerificationHelper(x, y) >= 0
  decreases x, y
{
  if x == 0 && y == 0 then
    0
  else if x > 0 then
    VerificationHelper(x - 1, y) + 1
  else
    VerificationHelper(x, y - 1) + 1
}

method ComplexAssertionExample(n: nat) returns (sum: nat)
  requires n >= 0
  ensures sum == n * (n + 1) / 2
  decreases n
{
  sum := 0;
  var counter := 0;
  
  while counter <= n
    invariant 0 <= counter <= n + 1
    invariant sum == (counter - 1) * counter / 2
    invariant sum >= 0
    decreases n - counter
  {
    // Multiple assertions to help verification
    assert sum >= 0;
    assert counter >= 0;
    assert sum == (counter - 1) * counter / 2;
    
    sum := sum + counter;
    counter := counter + 1;
    
    // More assertions after update
    assert sum >= 0;
    assert counter >= 0;
    assert sum == (counter - 1) * counter / 2;
  }
  
  // Final verification assertions
  assert counter == n + 1;
  assert sum == n * (n + 1) / 2;
}