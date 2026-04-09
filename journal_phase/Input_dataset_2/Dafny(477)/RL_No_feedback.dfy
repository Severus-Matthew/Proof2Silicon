// Function to calculate x raised to the power y
function Power(x: nat, y: nat): nat
  decreases y
{
  if y == 0 then
    1
  else
    x * Power(x, y - 1)
}

// Specialized function for calculating 2^y
function Pow2(y: nat): nat
{
  Power(2, y)
}

method Main()
{
  var y: nat := 10;
  
  var result := Pow2(y);
  
  print "2 raised to the power of ", y, " is ", result, "\n";
  // Expected output: 1024
  
  // Additional test cases
  print "2^0 = ", Pow2(0), "\n";      // Expected: 1
  print "2^1 = ", Pow2(1), "\n";      // Expected: 2
  print "2^3 = ", Pow2(3), "\n";      // Expected: 8
  print "2^5 = ", Pow2(5), "\n";      // Expected: 32
}

// Proof lemmas for power calculation
lemma PowerBase()
  ensures Power(2, 1) == 2
{
}

lemma PowerInductive(x: nat, y: nat)
  requires y > 0
  ensures Power(x, y + 1) == x * Power(x, y)
{
}

lemma PowerProperty(x: nat, y: nat)
  ensures Power(x, y) == if y == 0 then 1 else x * Power(x, y - 1)
{
}

// Lemma specifically for Pow2
lemma Pow2Property(y: nat)
  ensures Pow2(y) == Power(2, y)
{
}

// Lemma for power multiplication property
lemma PowerMult(y: nat)
  requires y > 0
  ensures Power(2, y) == 2 * Power(2, y - 1)
{
}

method Main2()
{
  var y: nat := 10;
  
  var result := Power(2, y);
  
  print "2 raised to the power of ", y, " is ", result, "\n";
  // Expected output: 1024
  
  // Additional test cases
  print "2^0 = ", Power(2, 0), "\n";      // Expected: 1
  print "2^1 = ", Power(2, 1), "\n";      // Expected: 2
  print "2^3 = ", Power(2, 3), "\n";      // Expected: 8
  print "2^5 = ", Power(2, 5), "\n";      // Expected: 32
}