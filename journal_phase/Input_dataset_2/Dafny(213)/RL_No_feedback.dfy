// A simple module demonstrating verification concepts
module RevisionableCounter {
  // A class that maintains a counter with an upper bound
  class Counter {
    // State variables
    var value: int
    var upperBound: int
    
    // Invariant: value must always be between 0 and upperBound (inclusive)
    invariant 0 <= value && value <= upperBound
    invariant upperBound >= 0
    
    // Constructor
    constructor(init: int, bound: int)
      requires 0 <= init && init <= bound
      requires bound >= 0
      ensures value == init && upperBound == bound
    {
      value := init;
      upperBound := bound;
    }
    
    // Method to increment the counter
    method Increment() 
      modifies this
      requires value < upperBound
      ensures value == old(value) + 1
    {
      // Update the value
      value := value + 1;
      
      // Assertion to verify the invariant holds
      assert 0 <= value && value <= upperBound;
    }
    
    // Method to decrement the counter
    method Decrement()
      modifies this
      requires value > 0
      ensures value == old(value) - 1
    {
      // Update the value
      value := value - 1;
      
      // Assertion to verify the invariant holds
      assert 0 <= value && value <= upperBound;
    }
    
    // Method to get the current value
    method GetValue() returns (v: int)
      ensures v == value
    {
      v := value;
    }
    
    // Method to compare with another counter
    method CompareWith(other: Counter) returns (comparison: int)
      requires other != null
      ensures comparison == (if value < other.value then -1 
                           else if value > other.value then 1 
                           else 0)
    {
      if value < other.value {
        comparison := -1;
      } else if value > other.value {
        comparison := 1;
      } else {
        comparison := 0;
      }
    }
  }
  
  // Main method to demonstrate usage - moved outside the Counter class
  method Main() {
    // Create a counter with initial value 5 and upper bound 10
    var c1 := new Counter(5, 10);
    
    // Verify initial state
    var v1 := c1.GetValue();
    assert v1 == 5;
    
    // Increment and verify
    c1.Increment();
    var v2 := c1.GetValue();
    assert v2 == 6;
    
    // Create another counter for comparison
    var c2 := new Counter(3, 10);
    
    // Compare counters
    var comp := c1.CompareWith(c2);
    assert comp == 1; // c1.value (6) > c2.value (3)
    
    // Demonstrate bounds checking
    // This would fail verification if uncommented:
    // while c1.GetValue() < 10
    //   invariant 0 <= c1.value <= c1.upperBound
    // {
    //   c1.Increment();
    // }
    
    // Final assertion
    var finalValue := c1.GetValue();
    assert finalValue <= 10;
  }
}