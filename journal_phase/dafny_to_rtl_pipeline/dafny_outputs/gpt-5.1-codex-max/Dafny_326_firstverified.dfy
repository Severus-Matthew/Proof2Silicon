method Sum(n: nat) returns (res: nat)
  ensures res == n * (n + 1) / 2
{
  var i: nat := 1;
  var sum: nat := 0;

  while i <= n
    invariant 1 <= i <= n + 1
    invariant sum == (i - 1) * i / 2
    decreases n - i + 1
  {
    sum := sum + i;
    i := i + 1;
  }

  res := sum;
}

method Main()
{
  var n: nat := 10;
  var s := Sum(n);
  assert s == n * (n + 1) / 2;
  print "Sum of numbers from 1 to ", n, " is ", s, "\n";
}
