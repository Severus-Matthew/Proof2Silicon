method Identity(n: nat) returns (result: nat)
  ensures result == n
{
  result := n;
  assert result == n;
}
