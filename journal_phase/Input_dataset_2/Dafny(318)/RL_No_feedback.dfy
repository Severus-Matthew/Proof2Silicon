method CheckOddDivisors(n: int) returns (isPrime: bool)
  requires n >= 2
  ensures isPrime == (forall k | 3 <= k <= n && k * k <= n && k % 2 == 1 :: n % k != 0)
{
  isPrime := true;
  var k := 3;
  while k * k <= n && k <= n
    invariant 3 <= k <= n + 1
    invariant isPrime == (forall j | 3 <= j < k && j * j <= n && j % 2 == 1 :: n % j != 0)
  {
    if k % 2 == 1 {
      if n % k == 0 {
        isPrime := false;
      }
    }
    k := k + 1;
  }
}