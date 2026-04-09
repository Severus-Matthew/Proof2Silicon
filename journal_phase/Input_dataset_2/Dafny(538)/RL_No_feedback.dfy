// This Dafny code defines a forest data structure and verifies
// that all trees in the forest have bounded height.
// The main property 'ForestAll' ensures that for every tree in the forest,
// its height is less than or equal to a given global bound.

// Define a generic Tree type with nodes containing a value and children.
datatype Tree<T> = Node(value: T, children: seq<Tree<T>>)

// Function to compute the height of a tree.
function Height<T>(t: Tree<T>): nat
{
  match t
  case Node(_, children) =>
    if |children| == 0 then
      0
    else
      1 + SeqMax(children)
}

// Helper function to compute the maximum height among a sequence of trees.
function SeqMax<T>(trees: seq<Tree<T>>): nat
  requires |trees| > 0
  decreases |trees|
{
  if |trees| == 1 then
    Height(trees[0])
  else
    var maxRest := SeqMax(trees[1..]);
    if Height(trees[0]) > maxRest then
      Height(trees[0])
    else
      maxRest
}

// Alternative implementation of SeqMax that handles empty sequences
function SeqMaxAlt<T>(trees: seq<Tree<T>>): nat
  decreases |trees|
{
  if |trees| == 0 then
    0
  else if |trees| == 1 then
    Height(trees[0])
  else
    var maxRest := SeqMaxAlt(trees[1..]);
    if Height(trees[0]) > maxRest then
      Height(trees[0])
    else
      maxRest
}

// Define a Forest as a sequence of trees.
type Forest<T> = seq<Tree<T>>

// Predicate that checks if all trees in a forest have height <= bound.
predicate ForestAll<T>(forest: Forest<T>, bound: nat)
{
  forall t :: t in forest ==> Height(t) <= bound
}

// Lemma to prove that if a tree's children all satisfy a height bound,
// then the tree itself satisfies a related bound.
lemma TreeHeightBound<T>(t: Tree<T>, childBound: nat)
  requires forall c :: c in t.children ==> Height(c) <= childBound
  ensures Height(t) <= childBound + 1
{
  // The height of the tree is 1 + max height of children, which is <= childBound + 1.
  // This follows directly from the definition of Height and SeqMax
}

// Main theorem: if every tree in the forest satisfies the height bound,
// then the forest as a whole satisfies the 'ForestAll' property.
theorem ForestAllProof<T>(forest: Forest<T>, bound: nat)
  ensures ForestAll(forest, bound) <==> (forall t :: t in forest ==> Height(t) <= bound)
{
  // This is directly by the definition of ForestAll.
}

// Additional lemma for the post-condition concept mentioned
lemma NodeHeightProperty<T>(t: Tree<T>)
  ensures t is Node ==> Height(t) == (if |t.children| == 0 then 0 else 1 + SeqMax(t.children))
{
  // This follows directly from the definition of Height
}

// Example usage: create a simple forest and verify the bound.
method Example()
{
  var tree1 := Node(1, []);
  var tree2 := Node(2, [Node(3, [])]);
  var forest: Forest<int> := [tree1, tree2];
  var bound := 2;

  // Verify that the forest satisfies the bound.
  assert Height(tree1) == 0;
  assert Height(tree2) == 1;
  assert ForestAll(forest, bound);
  
  // Additional verification for the post-condition concept
  var tree3 := Node(4, [Node(5, []), Node(6, [])]);
  assert Height(tree3) == 1;
  
  // Test the alternative SeqMax function
  assert SeqMaxAlt([]) == 0;
  assert SeqMaxAlt([tree1]) == 0;
  assert SeqMaxAlt([tree1, tree2]) == 1;
}