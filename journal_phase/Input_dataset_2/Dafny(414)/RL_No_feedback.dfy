function nonZeroReturn(x: int): int
  ensures x == 0 ==> nonZeroReturn(x) == -1
  ensures x != 0 ==> nonZeroReturn(x) == -x
{
  if x == 0 then -1 else -x
}

method test() {
  // Test with zero input
  var zeroResult := nonZeroReturn(0);
  assert zeroResult == -1;
  
  // Test with positive non-zero input
  var posResult := nonZeroReturn(5);
  assert posResult == -5;
  
  // Test with negative non-zero input  
  var negResult := nonZeroReturn(-3);
  assert negResult == 3;  // -(-3) = 3
  
  print "All tests passed!\n";
}