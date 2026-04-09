function Power(N: nat): nat 
  decreases N
{
  if N == 0 then 1 else 2 * Power(N - 1)
}

method ComputePower(N: nat) returns (y: nat)
  ensures y >= N
  ensures exists k: nat :: y == Power(k)
  ensures forall k: nat :: Power(k) >= N ==> y <= Power(k)
{
  y := 1;
  var exponent: nat := 0;
  
  while y < N
    invariant y == Power(exponent)
    invariant y >= 1
    invariant forall k: nat :: k <= exponent ==> Power(k) <= y
    decreases N - y
  {
    y := y * 2;
    exponent := exponent + 1;
  }
}