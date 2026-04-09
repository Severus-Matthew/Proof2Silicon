// Model of a closure system with failure conditions
datatype Result<T> = Success(value: T) | Failure

// A closure operation that might fail
function Closure<T>(input: T): Result<T>
  // Proper specification - at minimum ensures the result is either Success or Failure
  ensures Closure(input).Success? || Closure(input).Failure?

// Property about closure and failures
lemma LemmaClosureNoFail<T>(x: T)
  requires forall y: T :: Closure(y).Success?
  ensures Closure(x).Success?
{
  // Trivial since precondition guarantees it for all y, including x
}

// Recursive structure with closure property
datatype Tree = Leaf | Node(value: int, left: Tree, right: Tree)

function TreeClosure(t: Tree): Result<Tree>
  decreases t
{
  match t
  case Leaf => Success(Leaf)
  case Node(v, l, r) =>
    var leftResult := TreeClosure(l);
    var rightResult := TreeClosure(r);
    if leftResult.Failure? || rightResult.Failure? then
      Failure
    else
      Success(Node(v, l, r))
}

// Verification that tree closure doesn't fail for well-formed trees
lemma TreeClosureAlwaysSucceeds(t: Tree)
  ensures TreeClosure(t).Success?
  decreases t
{
  match t
  case Leaf =>
    // Base case: Leaf always succeeds - Dafny can verify this automatically
  case Node(v, l, r) =>
    // Inductive step: if both subtrees succeed, node succeeds
    TreeClosureAlwaysSucceeds(l);
    TreeClosureAlwaysSucceeds(r);
    // The recursive calls give us that TreeClosure(l).Success? and TreeClosure(r).Success?
    // Now we need to show that TreeClosure(Node(v, l, r)).Success?
    // By the definition of TreeClosure, this holds when both subtrees succeed
    // Dafny can verify this from the function definition
}

// Type reduction system
datatype Type = Base | Arrow(source: Type, target: Type)

function TypeReduce(t: Type): Result<Type>
  decreases t
{
  match t
  case Base => Success(Base)
  case Arrow(s, t2) =>
    var sReduced := TypeReduce(s);
    var tReduced := TypeReduce(t2);
    if sReduced.Failure? || tReduced.Failure? then
      Failure
    else
      Success(Arrow(s, t2))
}

// Verification that type reduction never fails
lemma TypeReduceNeverFails(t: Type)
  ensures TypeReduce(t).Success?
  decreases t
{
  match t
  case Base =>
    // Base case - explicitly show it succeeds
  case Arrow(s, t2) =>
    // Inductive case
    TypeReduceNeverFails(s);
    TypeReduceNeverFails(t2);
    // The recursive calls give us that TypeReduce(s).Success? and TypeReduce(t2).Success?
    // By the definition of TypeReduce, Arrow case succeeds when both components succeed
}

// Helper lemma to strengthen the proof
lemma TypeReduceAlwaysSucceedsForAll(t: Type)
  ensures TypeReduce(t).Success?
  decreases t
{
  TypeReduceNeverFails(t);
}

// Main verification system
method VerifySystem()
{
  // Test with a simple tree
  var tree := Node(1, Node(2, Leaf, Leaf), Node(3, Leaf, Leaf));
  TreeClosureAlwaysSucceeds(tree);
  assert TreeClosure(tree).Success?;
  
  // Test with types - use a simpler type to avoid recursion depth issues
  var typ := Arrow(Base, Base);
  TypeReduceNeverFails(typ);
  assert TypeReduce(typ).Success?;
  
  // Test with a slightly more complex type
  var typ2 := Arrow(Arrow(Base, Base), Base);
  TypeReduceNeverFails(typ2);
  assert TypeReduce(typ2).Success?;
  
  // Test with more complex types
  var typ3 := Arrow(Base, Arrow(Base, Base));
  TypeReduceNeverFails(typ3);
  assert TypeReduce(typ3).Success?;
  
  // Test with even more complex type
  var typ4 := Arrow(Arrow(Base, Arrow(Base, Base)), Base);
  TypeReduceNeverFails(typ4);
  assert TypeReduce(typ4).Success?;
  
  // General property: if something doesn't fail in closure,
  // then it's successfully closed
  var x: Tree := Leaf;
  
  // Additional verification for completeness
  var tree2 := Leaf;
  TreeClosureAlwaysSucceeds(tree2);
  assert TreeClosure(tree2).Success?;
  
  var tree3 := Node(5, Leaf, Leaf);
  TreeClosureAlwaysSucceeds(tree3);
  assert TreeClosure(tree3).Success?;
  
  // Verify that all our test cases actually hold
  // These assertions should all pass
  assert TreeClosure(tree).Success?;
  assert TreeClosure(tree2).Success?;
  assert TreeClosure(tree3).Success?;
  assert TypeReduce(typ).Success?;
  assert TypeReduce(typ2).Success?;
  assert TypeReduce(typ3).Success?;
  assert TypeReduce(typ4).Success?;
  
  // Additional verification to ensure no failures
  assert !TreeClosure(tree).Failure?;
  assert !TreeClosure(tree2).Failure?;
  assert !TreeClosure(tree3).Failure?;
  assert !TypeReduce(typ).Failure?;
  assert !TypeReduce(typ2).Failure?;
  assert !TypeReduce(typ3).Failure?;
  assert !TypeReduce(typ4).Failure?;
}