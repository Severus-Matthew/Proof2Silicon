class TwoStacks {
  // The array that holds both stacks
  var arr: array<int>;
  
  // Top indices for both stacks
  var top1: int;  // grows from left to right
  var top2: int;  // grows from right to left
  
  // Maximum capacity of the array
  ghost var capacity: int;
  
  // Constructor
  constructor (n: int)
    requires n > 0
    ensures Valid()
    ensures capacity == n
    ensures top1 == 0 && top2 == n - 1
  {
    arr := new int[n];
    top1 := 0;
    top2 := n - 1;
    capacity := n;
  }
  
  // Valid predicate - ensures both stacks don't overlap
  predicate Valid()
    reads this, arr
  {
    && arr != null
    && arr.Length == capacity
    && 0 <= top1
    && top1 <= top2 + 1  // +1 because they can be adjacent when full
    && top2 < capacity
    && (forall i :: 0 <= i < top1 ==> arr[i] != 0)  // Stack1 elements are initialized
    && (forall i :: top2 < i < capacity ==> arr[i] != 0)  // Stack2 elements are initialized
  }
  
  // Check if stack1 is empty
  method isEmpty1() returns (b: bool)
    requires Valid()
    ensures b == (top1 == 0)
  {
    b := top1 == 0;
  }
  
  // Check if stack2 is empty
  method isEmpty2() returns (b: bool)
    requires Valid()
    ensures b == (top2 == capacity - 1)
  {
    b := top2 == capacity - 1;
  }
  
  // Push element to stack1
  method push1(x: int) returns (success: bool)
    requires Valid()
    modifies this, arr
    ensures Valid()
    ensures success ==> top1 == old(top1) + 1
    ensures !success ==> top1 == old(top1)  // Stack full
    ensures success ==> arr[old(top1)] == x
  {
    if top1 > top2 {
      success := false;
    } else {
      arr[top1] := x;
      top1 := top1 + 1;
      success := true;
    }
  }
  
  // Push element to stack2
  method push2(x: int) returns (success: bool)
    requires Valid()
    modifies this, arr
    ensures Valid()
    ensures success ==> top2 == old(top2) - 1
    ensures !success ==> top2 == old(top2)  // Stack full
    ensures success ==> arr[old(top2)] == x
  {
    if top1 > top2 {
      success := false;
    } else {
      arr[top2] := x;
      top2 := top2 - 1;
      success := true;
    }
  }
  
  // Pop element from stack1
  method pop1() returns (x: int)
    requires Valid()
    requires top1 > 0  // Stack1 not empty
    modifies this
    ensures Valid()
    ensures top1 == old(top1) - 1
    ensures x == old(arr)[old(top1) - 1]
  {
    top1 := top1 - 1;
    x := arr[top1];
  }
  
  // Pop element from stack2
  method pop2() returns (x: int)
    requires Valid()
    requires top2 < capacity - 1  // Stack2 not empty
    modifies this
    ensures Valid()
    ensures top2 == old(top2) + 1
    ensures x == old(arr)[old(top2) + 1]
  {
    top2 := top2 + 1;
    x := arr[top2];
  }
  
  // Peek at top of stack1
  method peek1() returns (x: int)
    requires Valid()
    requires top1 > 0
    ensures x == arr[top1 - 1]
  {
    x := arr[top1 - 1];
  }
  
  // Peek at top of stack2
  method peek2() returns (x: int)
    requires Valid()
    requires top2 < capacity - 1
    ensures x == arr[top2 + 1]
  {
    x := arr[top2 + 1];
  }
}

// Test method to verify the implementation
method TestTwoStacks() {
  var ts := new TwoStacks(5);
  
  // Test pushing to both stacks
  var success1 := ts.push1(10);
  var success2 := ts.push2(20);
  var success3 := ts.push1(30);
  var success4 := ts.push2(40);
  var success5 := ts.push1(50);
  
  // This should fail - stack is full
  var success6 := ts.push2(60);
  assert !success6;
  
  // Test popping
  var x1 := ts.pop1();
  var x2 := ts.pop2();
  assert x1 == 50;
  assert x2 == 40;
}