ghost function factorialSpec(n: nat): nat
  decreases n
{
  if n == 0 then 1 else n * factorialSpec(n - 1)
}

method ComputeFactorial(n: nat) returns (res: nat)
  ensures res == factorialSpec(n)
{
  var i: nat := 0;
  res := 1;
  while i < n
    invariant 0 <= i <= n
    invariant res == factorialSpec(i)
    decreases n - i
  {
    i := i + 1;
    res := res * i;
  }
}

method Main()
{
  var r0 := ComputeFactorial(0);
  assert r0 == 1;
  var r1 := ComputeFactorial(1);
  assert r1 == 1;
  var r5 := ComputeFactorial(5);
  assert r5 == 120;
  var r6 := ComputeFactorial(6);
  assert r6 == 720;
  var r7 := ComputeFactorial(7);
  assert r7 == 5040;
}
