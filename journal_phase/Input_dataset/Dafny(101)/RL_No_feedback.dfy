// Predicate to check if a number is even
predicate is_even(x: int)
{
  x % 2 == 0
}

// Function to count even numbers from 0 to x (inclusive)
function FooCount(x: int): int
  requires x >= 0
  decreases x
{
  if x == 0 then
    (if is_even(0) then 1 else 0)
  else
    FooCount(x - 1) + (if is_even(x) then 1 else 0)
}

// Method to compute cumulative counts of even numbers
method ComputeFooCounts(n: int, a: array<int>)
  requires n >= 0
  requires a.Length >= n
  modifies a
  ensures forall i :: 0 <= i < n ==> a[i] == FooCount(i)
{
  var i: int := 0;
  
  while i < n
    invariant 0 <= i <= n
    invariant forall j :: 0 <= j < i ==> a[j] == FooCount(j)
  {
    a[i] := FooCount(i);
    i := i + 1;
  }
}

// Main method with verification
method Main()
{
  var n: int := 10;
  var a: array<int> := new int[n];
  
  // Initialize array
  var init_i: int := 0;
  while init_i < n
    invariant 0 <= init_i <= n
    invariant forall j :: 0 <= j < init_i ==> a[j] == 0
  {
    a[init_i] := 0;
    init_i := init_i + 1;
  }
  
  ComputeFooCounts(n, a);
  
  // Verification of specific values
  assert a[0] == 1;  // 0 is even
  assert a[1] == 1;  // 0 is even, 1 is odd
  assert a[2] == 2;  // 0 and 2 are even
  assert a[3] == 2;  // 0 and 2 are even
  assert a[4] == 3;  // 0, 2, 4 are even
  
  // Print array contents
  print "Array contents: ";
  var print_i: int := 0;
  while print_i < n
    invariant 0 <= print_i <= n
  {
    print a[print_i], " ";
    print_i := print_i + 1;
  }
  print "\n";
}