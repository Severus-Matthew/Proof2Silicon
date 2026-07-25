// This Dafny program defines a comparison function `cmp` on integers
// and proves standard order properties: reflexivity, antisymmetry, and transitivity.

module ComparisonProperties {
  // A comparison function on integers:
  // Returns:
  //   -1 if x < y
  //    0 if x == y
  //    1 if x > y
  function cmp(x: int, y: int): int {
    if x < y then -1 else if x == y then 0 else 1
  }

  // Lemma: reflexivity
  // For all integers x, cmp(x, x) == 0
  lemma Reflexive(x: int)
    ensures cmp(x, x) == 0
  {
    assert cmp(x, x) == 0;
  }

  // Lemma: antisymmetry
  // If cmp(x, y) <= 0 and cmp(y, x) <= 0, then x == y
  // Interpreting cmp(x,y) <= 0 as x <= y.
  lemma Antisymmetric(x: int, y: int)
    requires cmp(x, y) <= 0 && cmp(y, x) <= 0
    ensures x == y
  {
    // cmp(x,y) <= 0 means x <= y
    // cmp(y,x) <= 0 means y <= x
    // Together, they imply x == y
    if x < y {
      // contradiction since cmp(x,y) <= 0 is true but implies x < y or x == y
      // and cmp(y,x) <= 0 would imply y <= x => not possible if x < y
      assert false;
    } else if y < x {
      // Similarly, contradiction
      assert false;
    } else {
      // x == y
      assert x == y;
    }
  }

  // Lemma: transitivity
  // If cmp(x, y) <= 0 and cmp(y, z) <= 0, then cmp(x, z) <= 0
  lemma Transitive(x: int, y: int, z: int)
    requires cmp(x, y) <= 0 && cmp(y, z) <= 0
    ensures cmp(x, z) <= 0
  {
    // cmp(x,y) <= 0 => x <= y
    // cmp(y,z) <= 0 => y <= z
    // Therefore, x <= z => cmp(x,z) <= 0
    if x <= y && y <= z {
      assert x <= z;
      assert cmp(x, z) <= 0;
    } else {
      // This branch is unreachable under the requires conditions
      assert false;
    }
  }

  // A simple main method for demonstration (optional)
  method Main() {
    // Example usage:
    var a := 3;
    var b := 5;
    var c := 5;

    // Reflexive property demonstration
    Reflexive(a);
    // Antisymmetric property demonstration
    Antisymmetric(b, c);
    // Transitivity property demonstration
    Transitive(a, b, c);
  }
}
