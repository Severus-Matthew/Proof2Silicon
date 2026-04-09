// Define the IsVowel predicate
predicate IsVowel(c: char) 
{
  c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u' ||
  c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U'
}

// Helper predicate to check no two successive vowels in a string
predicate NoSuccessiveVowels(s: string) 
{
  forall i :: 0 <= i < |s| - 1 ==> !(IsVowel(s[i]) && IsVowel(s[i + 1]))
}

// Define the CountVowelNeighbors method
method CountVowelNeighbors(str: string, target: string) returns (count: int)
  requires |str| == |target|  // Both strings must have the same length
  requires NoSuccessiveVowels(str)  // No two successive vowels in the input string
  requires NoSuccessiveVowels(target)  // No two successive vowels in the target string
  ensures 0 <= count <= 2 * |str|  // Count is between 0 and twice the string length
{
  count := 0;
  var n := |str|;
  
  // Use a for loop to iterate through str string
  for i := 0 to n - 1
    invariant 0 <= i <= n
    invariant count == 2 * (count of indices j where 0 <= j < i && IsVowel(str[j]) && IsVowel(target[j]))
    invariant 0 <= count <= 2 * i
  {
    if IsVowel(str[i]) && IsVowel(target[i]) {
      count := count + 2;  // Count each vowel position (if both strings have vowels at same index)
    }
  }
}

// Test the method with assertions
method TestCountVowelNeighbors() 
{
  // Test case 1: empty strings
  var result1 := CountVowelNeighbors("", "");
  assert result1 == 0;
  
  // Test case 2: "cat" with target "dog" (no vowels in either)
  var result2 := CountVowelNeighbors("cat", "dog");
  assert result2 == 0;
  
  // Test case 3: "abc" with target "def" (no vowels at all)
  var result3 := CountVowelNeighbors("abc", "def");
  assert result3 == 0;
  
  // Test case 4: "hll" with target "eou" (vowels only in target)
  var result4 := CountVowelNeighbors("hll", "eou");
  assert result4 == 0;
  
  // Test case 5: "aei" with target "oua" 
  // This should fail precondition due to successive vowels in both strings
  
  // Test case 6: "hello" with target "world" 
  // str: h e l l o (vowels at positions 1,4)
  // target: w o r l d (vowels at position 1)
  // Only position 1 has vowels in both: count = 2
  var result6 := CountVowelNeighbors("hello", "world");
  assert result6 == 2;
  
  // Test case 7: "aeiou" with target "aeiou" 
  // This should fail precondition due to successive vowels
  
  // Test case 8: "a" with target "e" (single vowels in both)
  var result8 := CountVowelNeighbors("a", "e");
  assert result8 == 2;
  
  print "All tests passed!\n";
}