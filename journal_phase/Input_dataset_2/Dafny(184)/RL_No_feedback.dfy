method Main() {
  var numbers := new real[55];
  
  // Initialize the array with the given values (-0.5125 repeated 55 times)
  var i := 0;
  while i < 55
    invariant 0 <= i <= 55
    invariant forall j :: 0 <= j < i ==> numbers[j] == -0.5125 as real
  {
    numbers[i] := -0.5125 as real;
    i := i + 1;
  }
  
  // Calculate the sum
  var sum: real := 0.0 as real;
  i := 0;
  while i < 55
    invariant 0 <= i <= 55
    invariant sum == (i as real) * (-0.5125 as real)
  {
    sum := sum + numbers[i];
    i := i + 1;
  }
  
  // Calculate the average
  var average := sum / (55.0 as real);
  
  // Verify properties
  assert sum == (55.0 as real) * (-0.5125 as real);
  assert average == -0.5125 as real by {
    calc {
      average;
      == sum / (55.0 as real);
      == ((55.0 as real) * (-0.5125 as real)) / (55.0 as real);
      == -0.5125 as real;
    }
  }
  
  print "Array contains 55 elements\n";
  print "Sum: ", sum, "\n";
  print "Average: ", average, "\n";
}