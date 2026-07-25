// A simple 1-dimensional cellular automaton in Dafny.
// This implementation demonstrates two elementary rules (Rule 30 and Rule 90)
// on a finite row of cells. The code is iterative (no recursion) and includes
// specifications, invariants, and comments to explain its structure and intent.

/// Computes the neighborhood index based on three boolean inputs.
/// The encoding is: left contributes 4, center contributes 2, right contributes 1.
/// This matches the standard mapping for elementary cellular automata where
/// 111 -> 7, 110 -> 6, ..., 001 -> 1, 000 -> 0.
function NeighborhoodIndex(left: bool, center: bool, right: bool): int
  ensures 0 <= NeighborhoodIndex(left, center, right) < 8
{
  (if left then 4 else 0) + (if center then 2 else 0) + (if right then 1 else 0)
}

/// Applies a single automaton step to the current row using the given rule.
/// The rule array must have length 8. The `next` array must have the same length
/// as `curr` and is overwritten with the computed state.
/// Boundary cells consider missing neighbors as 'false' (inactive).
method ApplyStep(rule: array<bool>, curr: array<bool>, next: array<bool>)
  requires rule.Length == 8
  requires curr.Length == next.Length
  modifies next
  ensures next.Length == curr.Length
{
  var i := 0;
  // Iterate over each cell in the current row.
  while i < curr.Length
    invariant 0 <= i <= curr.Length
    invariant curr.Length == next.Length
    invariant rule.Length == 8
  {
    // Compute neighborhood values with safe boundary checks.
    var left := false;
    if i > 0 {
      left := curr[i - 1];
    }
    var center := curr[i];
    var right := false;
    if i + 1 < curr.Length {
      right := curr[i + 1];
    }
    var idx := NeighborhoodIndex(left, center, right);
    // By the postcondition of NeighborhoodIndex, idx is between 0 and 7.
    assert 0 <= idx < rule.Length;
    next[i] := rule[idx];
    i := i + 1;
  }
}

/// Prints a row of boolean cells, using '#' for true and '.' for false.
method PrintRow(row: array<bool>)
{
  var i := 0;
  while i < row.Length
    invariant 0 <= i <= row.Length
  {
    if row[i] {
      print "#";
    } else {
      print ".";
    }
    i := i + 1;
  }
}

/// Entry point: sets up two rules (Rule 30 and Rule 90),
/// runs the automaton for a fixed number of steps, and prints the final rows.
method Main()
{
  // Configuration parameters.
  var length := 15;
  var steps := 10;

  // Initialize the current row with a single active cell in the center.
  var current := new bool[length];
  var centerIndex := length / 2;
  current[centerIndex] := true;

  // Prepare the next row buffer.
  var next := new bool[length];

  // Define Rule 30 (binary 00011110, lowest bit corresponds to pattern 000).
  var rule30 := new bool[8];
  rule30[0] := false; // 000 -> 0
  rule30[1] := true;  // 001 -> 1
  rule30[2] := true;  // 010 -> 1
  rule30[3] := true;  // 011 -> 1
  rule30[4] := true;  // 100 -> 1
  rule30[5] := false; // 101 -> 0
  rule30[6] := false; // 110 -> 0
  rule30[7] := false; // 111 -> 0

  // Run the automaton for the given number of steps with Rule 30.
  var s := 0;
  while s < steps
    invariant 0 <= s <= steps
    invariant current.Length == length && next.Length == length
    invariant rule30.Length == 8
    invariant fresh(current) && fresh(next)
  {
    ApplyStep(rule30, current, next);
    // Swap buffers: current becomes the newly computed row.
    var tmp := current;
    current := next;
    next := tmp;
    s := s + 1;
  }

  print "Final state with Rule 30:\n";
  PrintRow(current);
  print "\n";

  // Reinitialize for a second run with a different rule (Rule 90).
  current := new bool[length];
  current[centerIndex] := true;
  next := new bool[length];

  // Define Rule 90 (binary 01011010, lowest bit corresponds to pattern 000).
  var rule90 := new bool[8];
  rule90[0] := false; // 000 -> 0
  rule90[1] := true;  // 001 -> 1
  rule90[2] := false; // 010 -> 0
  rule90[3] := true;  // 011 -> 1
  rule90[4] := true;  // 100 -> 1
  rule90[5] := false; // 101 -> 0
  rule90[6] := true;  // 110 -> 1
  rule90[7] := false; // 111 -> 0

  s := 0;
  while s < steps
    invariant 0 <= s <= steps
    invariant current.Length == length && next.Length == length
    invariant rule90.Length == 8
    invariant fresh(current) && fresh(next)
  {
    ApplyStep(rule90, current, next);
    // Swap buffers for the next iteration.
    var tmp2 := current;
    current := next;
    next := tmp2;
    s := s + 1;
  }

  print "Final state with Rule 90:\n";
  PrintRow(current);
  print "\n";
}
