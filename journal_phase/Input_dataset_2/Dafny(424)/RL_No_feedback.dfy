method Allow42(x: int, y: int) returns (result: int)
  requires y != 0  // Precondition to avoid division by zero
  ensures y != 42 ==> result == x / y
  ensures y == 42 ==> result == 0
{
  if y == 42 {
    result := 0;
  } else {
    result := x / y;
  }
}

method Forbid42(x: int, y: int) returns (result: bool)
  ensures result == (y != 42)
{
  result := y != 42;
}