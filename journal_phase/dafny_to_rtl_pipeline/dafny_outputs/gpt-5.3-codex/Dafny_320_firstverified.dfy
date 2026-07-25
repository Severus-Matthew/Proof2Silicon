method LastDigit(n: int) returns (d: int)
  requires n >= 0
  ensures d == n % 10
  ensures 0 <= d < 10
{
  d := n % 10;
  assert 0 <= d < 10;
}
