module Main {
  // Linear search that finds the first index where predicate P holds
  method LinearSearch0<T(==)>(list: seq<T>, P: T -> bool) returns (index: int)
    ensures 0 <= index <= |list|
    ensures index < |list| ==> P(list[index])
    ensures forall i :: 0 <= i < index ==> !P(list[i])
  {
    index := 0;
    
    // Search through the list
    while index < |list| && !P(list[index])
      invariant 0 <= index <= |list|
      invariant forall i :: 0 <= i < index ==> !P(list[i])
    {
      index := index + 1;
    }
  }

  // Alternative linear search that takes an element to find
  method LinearSearch1<T(==)>(list: seq<T>, x: T) returns (index: int)
    ensures 0 <= index <= |list|
    ensures index < |list| ==> list[index] == x
    ensures forall i :: 0 <= i < index ==> list[i] != x
  {
    index := 0;
    
    // Search for x in the list
    while index < |list| && list[index] != x
      invariant 0 <= index <= |list|
      invariant forall i :: 0 <= i < index ==> list[i] != x
    {
      index := index + 1;
    }
  }

  // Test method with specific predicate (finding even numbers)
  method TestLinearSearch() 
  {
    var list := [4, 7, 2, 5, 1, 3];
    
    // Test LinearSearch0 with predicate for even numbers
    var evenIndex := LinearSearch0(list, x => x % 2 == 0);
    print "First even number at index: ", evenIndex, "\n";
    
    // Test LinearSearch1 to find specific element
    var searchFor := 5;
    var foundIndex := LinearSearch1(list, searchFor);
    print "Element ", searchFor, " found at index: ", foundIndex, "\n";
    
    // Verify correctness
    assert evenIndex == 0; // First even number (4) is at index 0
    assert foundIndex == 3; // Number 5 is at index 3
    
    // Test case where element is not found
    var notFoundIndex := LinearSearch1(list, 10);
    print "Element 10 found at index: ", notFoundIndex, "\n";
    assert notFoundIndex == |list|; // Should be equal to list length when not found
  }

  // Main method to run tests
  method Main() 
  {
    print "=== Testing Linear Search ===\n";
    TestLinearSearch();
    print "=== Tests Completed ===\n";
  }
}