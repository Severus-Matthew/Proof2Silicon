method ComputeFactorial(n: int) returns (result: int)
  requires n >= 0
  ensures result == Factorial(n)
{
  result := 1;
  var i := 1;
  
  while i <= n
    invariant 0 <= i <= n + 1
    invariant result == Factorial(i - 1)
  {
    result := result * i;
    i := i + 1;
  }
}

function Factorial(n: int): int
  requires n >= 0
  decreases n
{
  if n == 0 then 1
  else n * Factorial(n - 1)
}

method Main()
{
  var f0: int;
  f0 := ComputeFactorial(0);
  print "0! = ", f0, "\n";
  assert f0 == 1;
  
  var f1: int;
  f1 := ComputeFactorial(1);
  print "1! = ", f1, "\n";
  assert f1 == 1;
  
  var f5: int;
  f5 := ComputeFactorial(5);
  print "5! = ", f5, "\n";
  assert f5 == 120;
  
  var f10: int;
  f10 := ComputeFactorial(10);
  print "10! = ", f10, "\n";
  assert f10 == 3628800;
}