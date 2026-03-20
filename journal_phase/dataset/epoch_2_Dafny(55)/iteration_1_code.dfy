// Example usage of ToArray method
method Main() {
  var seq1: seq<int> := [1, 2, 3, 4, 5];
  var arr1: array<int> := ToArray(seq1);
  
  // Verify properties
  assert arr1.Length == 5;
  assert arr1[0] == 1;
  assert arr1[1] == 2;
  assert arr1[2] == 3;
  assert arr1[3] == 4;
  assert arr1[4] == 5;
  
  print "Array elements: ";
  var i: int := 0;
  while i < arr1.Length {
    print arr1[i], " ";
    i := i + 1;
  }
  print "\n";
}