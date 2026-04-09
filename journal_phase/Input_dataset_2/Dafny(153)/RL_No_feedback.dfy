method Example() {
  var x := 0;
  
  // Simple assertion
  assert x == 0;
  
  // Loop with invariant
  while x < 5
    invariant 0 <= x <= 5
    decreases 5 - x
  {
    x := x + 1;
  }
  
  // Post-loop assertion
  assert x == 5;
  
  // Another example with array
  var arr := new int[3];
  arr[0] := 1;
  arr[1] := 2;
  arr[2] := 3;
  
  // Sum calculation
  var sum := 0;
  var i := 0;
  while i < arr.Length
    invariant 0 <= i <= arr.Length
    invariant sum == Sum(arr[..], i)
    decreases arr.Length - i
  {
    sum := sum + arr[i];
    i := i + 1;
  }
  
  assert sum == 6;
}

// Helper function to calculate sum of first n elements
function Sum(arr: seq<int>, n: int): int
  requires 0 <= n <= |arr|
  decreases n
{
  if n == 0 then 0
  else Sum(arr, n-1) + arr[n-1]
}