method Main()
{
  // 1. method declaration, 2. variable declaration, 3. assignment,
  // 4. conditional, 5. while loop, 6. loop invariant,
  // 7. assertion, 8. sequence usage, 9. forall statement, 10. termination metric
  var n: int := 10;
  var i: int := 0;
  var a: array<int> := new int[n];
  while i < n
    invariant 0 <= i <= n
    invariant a.Length == n
    invariant forall k :: 0 <= k < i ==> a[k] == k * k
    decreases n - i
  {
    a[i] := i * i;
    i := i + 1;
  }

  assert forall k :: 0 <= k < n ==> a[k] == k * k;

  var s: seq<int> := a[..];
  assert |s| == n;

  var sum: int := 0;
  i := 0;
  while i < n
    invariant 0 <= i <= n
    invariant sum == i * (i - 1) * (2 * i - 1) / 6
    decreases n - i
  {
    sum := sum + a[i];
    i := i + 1;
  }

  if n > 0 {
    assert a[0] == 0;
  } else {
    assert n == 0;
  }
}
