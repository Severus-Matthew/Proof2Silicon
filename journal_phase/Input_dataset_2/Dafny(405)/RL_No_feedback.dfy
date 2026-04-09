// Set Properties Lemmas

// Helper function for max
function max(a: nat, b: nat): nat
{
  if a >= b then a else b
}

// Lemma 1: If |sets1| > |sets2|, then |sets1 ∪ sets2| >= |sets1|
//          else if |sets1| < |sets2|, then |sets1 ∪ sets2| >= |sets2|
lemma LemmaUnionSize<T>(sets1: set<T>, sets2: set<T>)
  ensures (|sets1| > |sets2| ==> |sets1 ∪ sets2| >= |sets1|) &&
          (|sets1| < |sets2| ==> |sets1 ∪ sets2| >= |sets2|)
{
  // The union always contains all elements from both sets
  // If sets1 is larger, the union must be at least as large as sets1
  if |sets1| > |sets2| {
    assert sets1 ⊆ sets1 ∪ sets2;
    assert |sets1 ∪ sets2| >= |sets1|;
  } else if |sets1| < |sets2| {
    assert sets2 ⊆ sets1 ∪ sets2;
    assert |sets1 ∪ sets2| >= |sets2|;
  }
}

// Lemma 2: Bound on the size of the union when sets are in decreasing order
lemma LemmaDecreasingOrder<T>(sets1: set<T>, sets2: set<T>)
  requires |sets1| >= |sets2|
  ensures |sets1 ∪ sets2| >= |sets1|
{
  // Since sets1 is larger than or equal to sets2, 
  // the union must contain at least all elements of sets1
  assert sets1 ⊆ sets1 ∪ sets2;
  assert |sets1 ∪ sets2| >= |sets1|;
}

// Lemma 3: Mutually exclusive sets have an empty intersection
lemma LemmaExclusive<T>(sets1: set<T>, sets2: set<T>)
  requires sets1 ∩ sets2 == {}
  ensures |sets1 ∩ sets2| == 0
{
  // Trivially true by precondition
  // The intersection is empty, so its size is 0
}

// Lemma 4: Set cardinality is monotonic - if a set has elements, its size is positive
lemma LemmaCardinalityMonotonic<T>(sets: set<T>)
  requires |sets| > 0
  ensures |sets| >= 1
{
  // If size is greater than 0, it must be at least 1
  // This follows from the definition of natural numbers
}

// Lemma 5: Simple bounds on cardinality properties
lemma LemmaCardinalityBounds<T>(sets: set<T>)
  ensures |sets| <= |sets| + 1
{
  // Trivially true - any number is less than or equal to itself plus 1
}

// Helper function for sum
function sum(sizes: seq<nat>): nat
  decreases |sizes|
{
  if |sizes| == 0 then 0
  else sizes[0] + sum(sizes[1..])
}

// Helper function for gcd
function gcd(a: nat, b: nat): nat
  requires a > 0 || b > 0
  decreases a + b
{
  if a == 0 then b
  else if b == 0 then a
  else if a > b then gcd(a - b, b)
  else gcd(a, b - a)
}

// Additional lemma: Intersection size property
lemma LemmaIntersection<T>(sets1: set<T>, sets2: set<T>, n: nat)
  requires |sets1 ∩ sets2| > n
  ensures |sets1 ∩ sets2| > n
{
  // Trivially true by precondition
}

// New lemma: Union size is at least the maximum of the two sets
lemma LemmaUnionSizeMax<T>(sets1: set<T>, sets2: set<T>)
  ensures |sets1 ∪ sets2| >= max(|sets1|, |sets2|)
{
  if |sets1| >= |sets2| {
    LemmaDecreasingOrder(sets1, sets2);
    assert |sets1 ∪ sets2| >= |sets1|;
    assert |sets1| == max(|sets1|, |sets2|);
  } else {
    LemmaDecreasingOrder(sets2, sets1);
    assert |sets1 ∪ sets2| >= |sets2|;
    assert |sets2| == max(|sets1|, |sets2|);
  }
}

method CheckProperties()
{
  // Test LemmaUnionSize
  var s1: set<int> := {1, 2, 3};
  var s2: set<int> := {2, 3, 4};
  LemmaUnionSize(s1, s2);
  
  // Test LemmaDecreasingOrder
  var s3: set<int> := {1, 2, 3, 4};
  var s4: set<int> := {3, 4};
  LemmaDecreasingOrder(s3, s4);
  
  // Test LemmaExclusive
  var s5: set<int> := {1, 2};
  var s6: set<int> := {3, 4};
  LemmaExclusive(s5, s6);
  
  // Test LemmaCardinalityMonotonic
  var s7: set<int> := {1};
  LemmaCardinalityMonotonic(s7);
  
  // Test LemmaCardinalityBounds
  var s8: set<int> := {1, 2, 3};
  LemmaCardinalityBounds(s8);
  
  // Test LemmaIntersection
  LemmaIntersection(s1, s2, 1);
  
  // Test LemmaUnionSizeMax
  LemmaUnionSizeMax(s1, s2);
}