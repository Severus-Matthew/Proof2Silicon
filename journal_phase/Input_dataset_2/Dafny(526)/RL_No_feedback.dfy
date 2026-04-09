module Pythagorean {
  import opened Math
  
  function CalculateHypotenuse(a: real, b: real): real
    requires a > 0.0 && b > 0.0
    ensures CalculateHypotenuse(a, b) == Math.sqrt(a*a + b*b)
  {
    Math.sqrt(a*a + b*b)
  }
  
  method Main() {
    var leg1: real := 3.0;
    var leg2: real := 4.0;
    var hypotenuse := CalculateHypotenuse(leg1, leg2);
    print "For a right triangle with legs ", leg1, " and ", leg2, "\n";
    print "The hypotenuse is: ", hypotenuse, "\n";
    // Verify: 3² + 4² = 9 + 16 = 25, √25 = 5
  }
}