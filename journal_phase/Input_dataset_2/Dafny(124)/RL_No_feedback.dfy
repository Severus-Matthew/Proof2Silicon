module Reverse {
  // Non-recursive reverse using sequence comprehension
  function reverse<T>(s: seq<T>): seq<T>
    reads {}
    ensures |reverse(s)| == |s|
    ensures forall i :: 0 <= i < |s| ==> reverse(s)[i] == s[|s| - 1 - i]
  {
    seq(|s|, i requires 0 <= i < |s| => s[|s| - 1 - i])
  }

  // Lemma proving that reverse preserves equality
  lemma ReversePreservesEquality<T>(S: seq<T>, Tseq: seq<T>)
    requires S == Tseq
    ensures reverse(S) == reverse(Tseq)
  {
    // This follows directly from the functional nature of reverse
  }

  method Main() {
    var S: seq<nat> := [1, 2, 3];
    var T: seq<nat> := [1, 2, 3];
    
    // Proof that if S = T, then reverse(S) = reverse(T)
    // This follows directly from the definition of reverse
    assert S == T ==> reverse(S) == reverse(T);
    
    // Verify with concrete examples
    assert reverse(S) == [3, 2, 1];
    assert reverse(T) == [3, 2, 1];
    assert reverse(S) == reverse(T);
    
    // Additional verification of reverse properties
    // Provide explicit type annotations for empty sequences
    assert reverse([]: seq<nat>) == [];
    assert reverse([1]) == [1];
    assert reverse([1, 2]) == [2, 1];
    
    // Test the lemma
    ReversePreservesEquality(S, T);
    
    print "All assertions verified!\n";
  }
}