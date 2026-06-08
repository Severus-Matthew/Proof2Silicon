class CheckSumCalculator {
  var stringData: seq<char>
  var checksumData: int64
  
  // Constructor
  constructor Init()
    ensures stringData == [] && checksumData == 1
  {
    stringData := [];
    checksumData := 1;
  }
  
  // Non-ghost compiled function to compute LS checksum
  function ComputeLSSum(s: seq<char>): int64
    ensures result > 0
  {
    var sum: int64 := 1;
    var i: int := 0;
    
    while i < |s|
      invariant 0 <= i <= |s|
      invariant sum > 0
    {
      var charVal: int64 := s[i] as int64;
      // LS algorithm: combine with bitwise XOR and rotation
      sum := (charVal << 1) ^ sum ^ (sum >> 1);
      i := i + 1;
    }
    
    sum
  }
  
  // Predicate to check if current checksum is valid
  predicate Valid()
    reads this
  {
    checksumData == ComputeLSSum(stringData) && checksumData > 0
  }
  
  // Get current checksum
  method GetChecksum() returns (checksum: int64)
    requires Valid()
    ensures checksum == checksumData
  {
    checksum := checksumData;
  }
  
  // Append a string and update checksum
  method Append(newString: seq<char>) returns (newChecksum: int64)
    requires Valid()
    ensures Valid()
    ensures stringData == old(stringData) + newString
    ensures newChecksum == checksumData
  {
    var i: int := 0;
    
    while i < |newString|
      invariant 0 <= i <= |newString|
      invariant Valid()
      invariant stringData == old(stringData) + newString[..i]
    {
      var charVal: int64 := newString[i] as int64;
      // Update checksum using LS algorithm
      checksumData := (charVal << 1) ^ checksumData ^ (checksumData >> 1);
      i := i + 1;
    }
    
    // Update string data
    stringData := stringData + newString;
    newChecksum := checksumData;
  }
  
  // Remove characters from the end and update checksum
  method RemoveLast(n: int) returns (newChecksum: int64)
    requires Valid()
    requires 0 <= n <= |stringData|
    ensures Valid()
    ensures |stringData| == |old(stringData)| - n
    ensures newChecksum == checksumData
  {
    if n == 0 {
      newChecksum := checksumData;
      return;
    }
    
    // Recompute checksum from scratch for simplicity
    // (More efficient implementations could reverse the computation)
    stringData := stringData[..|stringData|-n];
    checksumData := ComputeLSSum(stringData);
    newChecksum := checksumData;
  }
  
  // Verify current checksum
  method Verify() returns (isValid: bool)
    ensures isValid == Valid()
  {
    isValid := checksumData == ComputeLSSum(stringData) && checksumData > 0;
  }
  
  // Reset to empty state
  method Reset()
    ensures Valid() && stringData == [] && checksumData == 1
  {
    stringData := [];
    checksumData := 1;
  }
}

// Test module to verify functionality
module TestCheckSumCalculator {
  method TestBasicOperations() 
  {
    var calc := new CheckSumCalculator.Init();
    var isValid: bool;
    
    // Test 1: Empty string should have checksum 1
    isValid := calc.Verify();
    assert isValid;
    assert calc.GetChecksum() == 1;
    
    // Test 2: Append single character
    var checksum1 := calc.Append(['a']);
    isValid := calc.Verify();
    assert isValid;
    
    // Test 3: Append multiple characters
    var checksum2 := calc.Append(['b', 'c', 'd']);
    isValid := calc.Verify();
    assert isValid;
    
    // Test 4: Remove characters
    var checksum3 := calc.RemoveLast(2);
    isValid := calc.Verify();
    assert isValid;
    
    // Test 5: Reset
    calc.Reset();
    isValid := calc.Verify();
    assert isValid;
    assert calc.GetChecksum() == 1;
    
    print "All tests passed!\n";
  }
  
  method Main() 
  {
    TestBasicOperations();
  }
}