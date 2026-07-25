abstract module Interface {
  // addSome should always return a value strictly greater than its input
  function addSome(n: int): int
    ensures addSome(n) > n
}

module Implementation refines Interface {
  // Concrete implementation: add 1 to any input n
  function addSome(n: int): int
    ensures addSome(n) > n
    ensures addSome(n) == n + 1
  {
    n + 1
  }

  // Lemma to illustrate that addSome satisfies the specification for any n
  lemma AddSomeCorrect(n: int)
    ensures addSome(n) == n + 1
    ensures addSome(n) > n
  {
    // Follows directly from the function body and postconditions
  }

  // Lemma for the specific case n = 5
  lemma AddSomeFive()
    ensures addSome(5) >= 6
    ensures addSome(5) == 6
  {
    // Directly evaluate addSome(5)
    assert addSome(5) == 6;
  }
}

module Mod2 {
  import opened Implementation

  // For inputs at least 5, addSome returns a value at least 6 and strictly greater than the input
  lemma Mod2Correct(m: int)
    requires m >= 5
    ensures addSome(m) >= 6
    ensures addSome(m) > m
  {
    assert addSome(m) == m + 1;
  }

  // Assert the concrete case addSome(5) >= 6
  method AssertFive() {
    assert addSome(5) >= 6;
  }
}

// A simple entry point to demonstrate usage and edge case checks
method Main() {
  // Check the property for a specific value
  assert Implementation.addSome(5) >= 6;

  // Check a negative value to cover edge cases
  var n := -10;
  assert Implementation.addSome(n) == n + 1;
  assert Implementation.addSome(n) > n;
}
