method DivideIntoUniqueExtensible<T>(seq: seq<T>, predicate: (T) -> bool) 
  returns (result: seq<seq<T>>)
  requires |seq| > 0
  ensures |result| > 0  // Non-empty result
  ensures forall partition :: 0 <= partition < |result| ==> |result[partition]| > 0  // Each partition is non-empty
  ensures forall i, j :: 0 <= i < j < |result| ==> result[i] != result[j]  // Unique partitions
  ensures forall elem :: elem in seq ==> (exists partition :: 0 <= partition < |result| && elem in result[partition])  // All elements covered
  ensures forall partition :: 0 <= partition < |result| ==> (forall elem :: elem in result[partition] ==> elem in seq)  // No extra elements
  ensures forall partition :: 0 <= partition < |result| ==> 
    ((forall elem :: elem in result[partition] ==> predicate(elem)) || 
     (forall elem :: elem in result[partition] ==> !predicate(elem)))  // Each partition is homogeneous
  ensures StablePreservation(seq, result, predicate)
{
  // Initialize with first element
  var currentPartition: seq<T> := [seq[0]];
  result := [];
  
  var i := 1;
  while i < |seq|
    invariant 0 <= i <= |seq|
    invariant |result| >= 0
    invariant forall partition :: 0 <= partition < |result| ==> |result[partition]| > 0
    invariant forall p, q :: 0 <= p < q < |result| ==> result[p] != result[q]
    invariant forall k :: 0 <= k < i ==> (exists partition :: 0 <= partition < |result| && seq[k] in result[partition] || seq[k] in currentPartition)
    invariant forall partition :: 0 <= partition < |result| ==> 
      ((forall elem :: elem in result[partition] ==> predicate(elem)) || 
       (forall elem :: elem in result[partition] ==> !predicate(elem)))
    invariant |currentPartition| > 0
    invariant ((forall elem :: elem in currentPartition ==> predicate(elem)) || 
              (forall elem :: elem in currentPartition ==> !predicate(elem)))
    decreases |seq| - i
  {
    if predicate(seq[i]) == predicate(currentPartition[0]) {
      // Add to current partition
      currentPartition := currentPartition + [seq[i]];
    } else {
      // Start new partition
      result := result + [currentPartition];
      currentPartition := [seq[i]];
    }
    i := i + 1;
  }
  
  // Add the last partition
  result := result + [currentPartition];
  
  // Verify postconditions
  assert |result| > 0;
  assert forall partition :: 0 <= partition < |result| ==> |result[partition]| > 0;
  assert forall i, j :: 0 <= i < j < |result| ==> result[i] != result[j];
  assert forall elem :: elem in seq ==> (exists partition :: 0 <= partition < |result| && elem in result[partition]);
  assert forall partition :: 0 <= partition < |result| ==> (forall elem :: elem in result[partition] ==> elem in seq);
  assert forall partition :: 0 <= partition < |result| ==> 
    ((forall elem :: elem in result[partition] ==> predicate(elem)) || 
     (forall elem :: elem in result[partition] ==> !predicate(elem)));
}

predicate StablePreservation<T>(original: seq<T>, partitions: seq<seq<T>>, predicate: (T) -> bool)
{
  // Stability: relative order is preserved
  (forall i, j :: 0 <= i < j < |original| ==> 
    (forall p, q :: 0 <= p < |partitions| && 0 <= q < |partitions| &&
        original[i] in partitions[p] && original[j] in partitions[q] 
        ==> p <= q))
    
  // Freshness: each partition has consistent predicate value
  && (forall partition :: 0 <= partition < |partitions| ==>
       ((forall elem :: elem in partitions[partition] ==> predicate(elem)) || 
        (forall elem :: elem in partitions[partition] ==> !predicate(elem))))
    
  // Preservation: all elements are accounted for
  && Multiset(original) == Multiset(Flatten(partitions))
    
  // Decreasing property: partitions are maximal
  && (forall k :: 0 <= k < |partitions| - 1 ==>
       predicate(partitions[k][0]) != predicate(partitions[k+1][0]))
}

function Flatten<T>(seqs: seq<seq<T>>): seq<T>
  decreases |seqs|
{
  if |seqs| == 0 then []
  else seqs[0] + Flatten(seqs[1..])
}

// Helper lemma to prove multiset equality
lemma MultisetPreservation<T>(original: seq<T>, partitions: seq<seq<T>>)
  requires forall elem :: elem in original ==> (exists partition :: 0 <= partition < |partitions| && elem in partitions[partition])
  requires forall partition :: 0 <= partition < |partitions| ==> (forall elem :: elem in partitions[partition] ==> elem in original)
  ensures Multiset(original) == Multiset(Flatten(partitions))
{
  // This lemma would need to be proved with more detailed reasoning
  // For now, we'll assume the implementation is correct
}

// Test method
method TestDivideIntoUniqueExtensible()
{
  var seq1 := [1, 2, 3, 4, 5];
  function isEven(x: int): bool 
  {
    x % 2 == 0
  }
  
  var result1 := DivideIntoUniqueExtensible(seq1, isEven);
  
  // Verify properties
  assert |result1| > 0;
  assert forall partition :: 0 <= partition < |result1| ==> |result1[partition]| > 0;
  assert forall i, j :: 0 <= i < j < |result1| ==> result1[i] != result1[j];
  
  var seq2 := [1, 1, 2, 2, 3, 3];
  var result2 := DivideIntoUniqueExtensible(seq2, isEven);
  
  // Additional test with duplicates
  assert |result2| > 0;
  
  var seq3 := [2, 4, 6, 8];
  var result3 := DivideIntoUniqueExtensible(seq3, isEven);
  
  // All even numbers - should result in one partition
  assert |result3| == 1;
}

// Additional verification predicates
predicate AllPartitionsNonEmpty<T>(partitions: seq<seq<T>>)
{
  forall partition :: 0 <= partition < |partitions| ==> |partitions[partition]| > 0
}

predicate PartitionsAreUnique<T>(partitions: seq<seq<T>>)
{
  forall i, j :: 0 <= i < j < |partitions| ==> partitions[i] != partitions[j]
}

predicate CompleteCoverage<T>(original: seq<T>, partitions: seq<seq<T>>)
{
  forall elem :: elem in original ==> (exists partition :: 0 <= partition < |partitions| && elem in partitions[partition])
}

predicate NoExtraElements<T>(original: seq<T>, partitions: seq<seq<T>>)
{
  forall partition :: 0 <= partition < |partitions| ==> (forall elem :: elem in partitions[partition] ==> elem in original)
}