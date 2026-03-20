class ToArrow {
  // Converts an array of integers to a string representation
  method ToArrow(input: array<int>) returns (output: string)
    ensures output != null
  {
    output := "";
    var i: int := 0;
    
    // Loop through array with proper bounds checking
    while i < input.Length
      invariant 0 <= i <= input.Length
      invariant output != null
    {
      // Convert each integer to string and append
      output := output + ToString(input[i]);
      i := i + 1;
      
      // Add separator between elements (except after last element)
      if i < input.Length {
        output := output + ", ";
      }
    }
  }
  
  // Helper method to convert int to string
  method ToString(n: int) returns (s: string)
    ensures s != null
  {
    // Simple conversion
    if n == 0 {
      s := "0";
    } else {
      s := "";
      var temp := n;
      var negative := temp < 0;
      if negative {
        temp := -temp;
      }
      
      while temp > 0
        invariant temp >= 0
        invariant s != null
      {
        var digit := temp % 10;
        s := ToChar(digit) + s;
        temp := temp / 10;
      }
      
      if negative {
        s := "-" + s;
      }
    }
  }
  
  // Helper to convert single digit to character
  method ToChar(digit: int) returns (c: string)
    requires 0 <= digit < 10
    ensures |c| == 1
  {
    var chars := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    c := chars[digit];
  }
  
  // Lemma to verify boundedness of array access
  lemma checkBoundedness(input: array<int>, i: int)
    requires 0 <= i < input.Length
    ensures input[i] == input[i]  // Trivial but helps with verification
  {
  }
}