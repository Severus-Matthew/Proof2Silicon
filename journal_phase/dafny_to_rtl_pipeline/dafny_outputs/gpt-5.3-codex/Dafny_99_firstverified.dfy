method ComputeStairs(n: nat) returns (ways: nat)
  ensures n == 0 ==> ways == 1
  ensures n == 1 ==> ways == 1
  ensures n >= 2 ==> ways > 0
{
  if n == 0 {
    ways := 1;
    return;
  }

  if n == 1 {
    ways := 1;
    return;
  }

  var prev2: nat := 1; // ways for 0 steps
  var prev1: nat := 1; // ways for 1 step
  var i: nat := 2;

  while i <= n
    invariant 2 <= i <= n + 1
    invariant prev2 > 0 && prev1 > 0
    decreases n - i + 1
  {
    var curr: nat := prev1 + prev2;
    prev2 := prev1;
    prev1 := curr;
    i := i + 1;
  }

  ways := prev1;
  assert ways > 0;
}
