method Max(a: int, b: int) returns (m: int)
  ensures m >= a && m >= b
  ensures m == a || m == b
{
  if a >= b {
    m := a;
  } else {
    m := b;
  }
}

method TestMax() {
  var x := Max(3, 5);
  assert x == 5;
  
  var y := Max(7, 2);
  assert y == 7;
  
  var z := Max(4, 4);
  assert z == 4;
}

method SumToN(n: nat) returns (s: nat)
  ensures s == n * (n + 1) / 2
{
  s := 0;
  var i: nat := 0;
  while i <= n
    invariant s == i * (i + 1) / 2
    invariant i <= n + 1
  {
    s := s + i;
    i := i + 1;
  }
}

method TestSum() {
  var s1 := SumToN(0);
  assert s1 == 0;
  
  var s2 := SumToN(5);
  assert s2 == 15;
  
  var s3 := SumToN(10);
  assert s3 == 55;
}