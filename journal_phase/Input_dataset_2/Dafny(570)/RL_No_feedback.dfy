method CalculateTriangleArea(base: real, height: real) returns (area: real)
  requires base >= 0.0 && height >= 0.0
  ensures area == 0.5 * base * height
{
  area := 0.5 * base * height;
}

method Main()
{
  // Test case 1: Integer values
  var base1 := 10.0;
  var height1 := 5.0;
  var area1 := CalculateTriangleArea(base1, height1);
  print "The area of the triangle with base ", base1, " and height ", height1, " is: ", area1, "\n";
  
  // Test case 2: Non-integer values
  var base2 := 7.5;
  var height2 := 3.2;
  var area2 := CalculateTriangleArea(base2, height2);
  print "The area of the triangle with base ", base2, " and height ", height2, " is: ", area2, "\n";
  
  // Test case 3: Zero base
  var base3 := 0.0;
  var height3 := 4.0;
  var area3 := CalculateTriangleArea(base3, height3);
  print "The area of the triangle with base ", base3, " and height ", height3, " is: ", area3, "\n";
  
  // Test case 4: Zero height
  var base4 := 6.0;
  var height4 := 0.0;
  var area4 := CalculateTriangleArea(base4, height4);
  print "The area of the triangle with base ", base4, " and height ", height4, " is: ", area4, "\n";
  
  // Test case 5: Both zero
  var base5 := 0.0;
  var height5 := 0.0;
  var area5 := CalculateTriangleArea(base5, height5);
  print "The area of the triangle with base ", base5, " and height ", height5, " is: ", area5, "\n";
}