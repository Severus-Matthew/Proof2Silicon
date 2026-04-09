datatype TreeNode = Leaf | Node(val: int, left: TreeNode, right: TreeNode)

function SumPath(root: TreeNode, target: int): bool
  decreases root
{
  match root
  case Leaf =>
    false
  case Node(v, left, right) =>
    // Check if this is a leaf node and its value equals the target
    if left == Leaf && right == Leaf then
      v == target
    else
      // Recursively check left and right subtrees with reduced target
      SumPath(left, target - v) || SumPath(right, target - v)
}

method Main() {
  // Test case 1
  var tree1 := Node(5,
    Node(4,
      Node(11,
        Node(7, Leaf, Leaf),
        Node(8, Leaf, Leaf)),
      Node(2,
        Node(5,
          Node(10, Leaf, Leaf),
          Node(3, Leaf, Leaf)),
        Node(1, Leaf, Leaf))),
    Node(6,
      Node(3,
        Node(4, Leaf, Leaf),
        Node(5, Leaf, Leaf)),
      Node(8, Leaf, Leaf)));
  
  assert SumPath(tree1, 24) == true;  // 5→4→11→4
  assert SumPath(tree1, 25) == false;

  // Test case 2
  var tree2 := Node(10,
    Node(3,
      Node(10, Leaf, Leaf),
      Node(15, Leaf, Leaf)),
    Node(6,
      Node(1,
        Node(5, Leaf, Leaf),
        Node(2, Leaf, Leaf)),
      Node(1, Leaf, Leaf)));

  assert SumPath(tree2, 12) == true;  // 10→3→10→-11? Let me recalculate...
  // Actually: 10 + 3 + 10 = 23, 10 + 3 + 15 = 28, 10 + 6 + 1 + 5 = 22, 10 + 6 + 1 + 2 = 19, 10 + 6 + 1 = 17
  // Wait, let me trace the actual paths:
  // Path 1: 10→3→10 = 23
  // Path 2: 10→3→15 = 28  
  // Path 3: 10→6→1→5 = 22
  // Path 4: 10→6→1→2 = 19
  // Path 5: 10→6→1 = 17
  // None equals 12... Let me check the tree structure again
  
  // Actually, looking at the tree structure:
  // Root: 10
  // Left: 3 with children 10 and 15
  // Right: 6 with left child 1 (which has children 5 and 2) and right child 1
  // So paths are:
  // 10→3→10 = 23
  // 10→3→15 = 28
  // 10→6→1→5 = 22
  // 10→6→1→2 = 19
  // 10→6→1 = 17
  // None equals 12, so this should be false
  
  assert SumPath(tree2, 12) == false;
  assert SumPath(tree2, 14) == false;

  print "All assertions passed\n";
}