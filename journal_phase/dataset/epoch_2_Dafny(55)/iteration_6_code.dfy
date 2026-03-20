module RL_No_feedback {
  // Define sequence types
  type SeqT
  type SeqE
  
  // Function to check membership
  function ismember(seqT: SeqT, seqE: SeqE, k: int): bool
    requires 0 <= k < |seqT|
  
  // Array wrapper for integer to string conversion
  class ToArrow {
    var value: int
    
    constructor (v: int)
      requires v >= 0
      ensures value == v
    
    method ToString() returns (s: string)
      ensures s != null
    {
      s := "value: " + value;
    }
  }
  
  // Main method demonstrating the functionality
  method Main() {
    var x: seq<int> := [1, 2, 3, 4, 5];
    var y: seq<int> := [2, 4];
    
    // Create ToArrow instances for array access demonstration
    var arrows: array<ToArrow> := new ToArrow[5];
    var i := 0;
    while i < 5
      invariant i <= 5
      invariant forall j :: 0 <= j < i ==> arrows[j] != null
    {
      arrows[i] := new ToArrow(i);
      i := i + 1;
    }
    
    // Demonstrate array access with proper bounds checking
    if arrows.Length > 0 {
      var s := arrows[0].ToString();
      print s;
    }
    
    // Demonstrate sequence operations
    var k: int := 2;
    if 0 <= k < |x| {
      // This would be where ismember would be called
      // var result := ismember(x, y, k);
      print "Valid index: ", k;
    }
  }
  
  // Helper method to demonstrate proper array bounds checking
  method SafeArrayAccess(arr: array<int>, index: int) returns (value: int)
    requires arr != null
    requires 0 <= index < arr.Length
    ensures value == arr[index]
  {
    value := arr[index];
  }
}