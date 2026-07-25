module Min {
  method MinOfTwo(a: int, b: int) returns (minValue: int)
    ensures minValue == a || minValue == b
    ensures minValue <= a && minValue <= b
  {
    if a <= b {
      minValue := a;
    } else {
      minValue := b;
    }
    // Postconditions are trivially satisfied by the above selection
    assert minValue <= a;
    assert minValue <= b;
  }

  // Simple test method to demonstrate usage
  method TestMin() {
    var x := 10;
    var y := 0;
    var m := MinOfTwo(x, y);
    assert m == 0;
    m := MinOfTwo(5, 5);
    assert m == 5;
    m := MinOfTwo(-3, 2);
    assert m == -3;
  }
}
