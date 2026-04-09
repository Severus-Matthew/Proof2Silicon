// Define a class with a ghost variable to track state
class MyClass {
  var a: int
  ghost var lastA: int

  // Constructor initializes a and lastA
  constructor() 
    ensures a == 0 && lastA == 0
  {
    a := 0;
    lastA := a;
  }

  // Method to update a and maintain ghost variable
  method updateA(newA: int)
    ensures a == newA
    ensures lastA == old(a)
  {
    lastA := a;
    a := newA;
  }

  // Helper method to verify postcondition - now with proper specification
  method verifyPostcondition() 
    ensures a == 1
  {
    updateA(1);
  }

  // Additional helper to demonstrate the ghost variable tracking
  method demonstrateTracking()
    ensures a == 2
  {
    verifyPostcondition();  // sets a to 1, lastA to 0
    updateA(2);             // sets a to 2, lastA to 1
  }
}

// Main method to test the class
method Main() {
  var c := new MyClass();
  
  // Test the demonstrateTracking method
  c.demonstrateTracking();
  assert c.a == 2;
  
  // Alternatively, manually test the sequence as suggested in the instructions
  var c2 := new MyClass();
  c2.updateA(1);
  c2.verifyPostcondition();  // This will update a to 1 again (though it's already 1)
  c2.updateA(2);
  assert c2.a == 2;
  
  // Add verification logic similar to the C++/C# style mentioned
  if (c2.a == 2) {
    print "Postcondition verified: a is 2\n";
  } else {
    print "Postcondition verification failed: a should be 2\n";
  }
}