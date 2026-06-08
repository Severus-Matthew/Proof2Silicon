module SequenceUtils {
  predicate Unique<T(==)>(s: seq<T>) {
    forall i, j :: 0 <= i < j < |s| ==> s[i] != s[j]
  }
}

module ArrayUtils {
  predicate EqualSequence(s1: seq<int>, s2: seq<int>) {
    s1 == s2
  }
  
  predicate UniqueSequence(s: seq<int>) {
    SequenceUtils.Unique(s)
  }
  
  method IsUnique(s: seq<int>) returns (isUnique: bool)
    ensures isUnique == SequenceUtils.Unique(s)
  {
    isUnique := SequenceUtils.Unique(s);
  }
  
  method IsEmpty(s: seq<int>) returns (isEmpty: bool)
    ensures isEmpty == (|s| == 0)
  {
    isEmpty := |s| == 0;
  }
}

method TestSequenceOperations() {
  var s1: seq<int> := [1, 2, 3];
  var s2: seq<int> := [1, 2, 3];
  var s3: seq<int> := [1, 2, 2, 3];
  
  // Test EqualSequence
  assert ArrayUtils.EqualSequence(s1, s2);
  assert !ArrayUtils.EqualSequence(s1, s3);
  
  // Test UniqueSequence
  assert ArrayUtils.UniqueSequence(s1);
  assert !ArrayUtils.UniqueSequence(s3);
  
  // Test IsUnique method
  var unique1: bool := ArrayUtils.IsUnique(s1);
  var unique3: bool := ArrayUtils.IsUnique(s3);
  assert unique1;
  assert !unique3;
  
  // Test IsEmpty method
  var emptySeq: seq<int> := [];
  var nonEmptySeq: seq<int> := [1];
  var isEmpty1: bool := ArrayUtils.IsEmpty(emptySeq);
  var isEmpty2: bool := ArrayUtils.IsEmpty(nonEmptySeq);
  assert isEmpty1;
  assert !isEmpty2;
  
  print "All tests passed!\n";
}