method rotated(a: int, b: int, c: int) returns (max1: int, max2: int, max3: int)
{
  // Get the three values
  var min1 := if a <= b && a <= c then a else if b <= a && b <= c then b else c;
  var min2 := if (a <= b && a <= c) || (a >= b && a <= c) then 
                if b <= c then b else c 
              else if b <= a && b <= c then 
                if a <= c then a else c 
              else 
                if a <= b then a else b;
  
  // Find the maximum value
  var nMax := if a >= b && a >= c then a else if b >= a && b >= c then b else c;
  
  // Initialize max values
  max1 := min1;
  max2 := min2;
  max3 := nMax;
  
  // Sort the three values in descending order
  if max1 < max2 {
    var temp := max1;
    max1 := max2;
    max2 := temp;
  }
  if max2 < max3 {
    var temp := max2;
    max2 := max3;
    max3 := temp;
  }
  if max1 < max2 {
    var temp := max1;
    max1 := max2;
    max2 := temp;
  }
}