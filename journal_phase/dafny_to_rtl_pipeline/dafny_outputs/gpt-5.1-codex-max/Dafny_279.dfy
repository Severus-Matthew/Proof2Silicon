// Computes the square root of 5 as a fixed numeric constant.
function Sqrt5(): real
  ensures Sqrt5() > 0.0
  ensures Sqrt5() < 5.0
{
  2.23606797749979
}

// Computes the perimeter of a pentagon given the length of one side.
method PentagonPerimeter(side: int) returns (perimeter: int)
  requires side >= 0
  ensures perimeter == 5 * side
  ensures perimeter >= 0
{
  perimeter := 5 * side;
}

// Computes the area of a pentagon given the length of one side,
// using the formula: 5 * side * (5 - sqrt(5)) / 2.
method PentagonArea(side: real) returns (area: real)
  requires side >= 0.0
  ensures area == 5.0 * side * (5.0 - Sqrt5()) / 2.0
  ensures side >= 0.0 ==> area >= 0.0
{
  var sqrt5 := Sqrt5();
  area := 5.0 * side * (5.0 - sqrt5) / 2.0;
}

method Main()
{
  var side: int := 3;
  var perimeter := PentagonPerimeter(side);
  assert perimeter == 15;
  assert perimeter >= 0;

  var rside: real := side as real;
  var area := PentagonArea(rside);
  // For a positive side length, the area computed by the formula is positive.
  assert area > 0.0;
}
