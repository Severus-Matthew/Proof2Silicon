method TwoSum(nums: array<int>, target: int) returns (result: (int, int))
  requires forall i, j :: 0 <= i < j < nums.Length ==> nums[i] != nums[j]  // All elements are distinct
  requires forall i :: 0 <= i < nums.Length ==> nums[i] >= 0  // Non-negative elements
  ensures (exists i, j :: 
    0 <= i < j < nums.Length && 
    nums[i] + nums[j] == target &&
    result == (i, j)) ||
    result == (-1, -1)  // Sentinel value when no solution exists
{
  var seen: map<int, int> := map[];  // Map from value to index
  
  for i := 0 to nums.Length - 1
    invariant 0 <= i <= nums.Length
    invariant forall k :: 0 <= k < i ==> nums[k] in seen
    invariant forall k :: 0 <= k < i ==> seen[nums[k]] == k
    // We don't need the invariant about not finding solution yet - it's implied by not returning
  {
    var complement := target - nums[i];
    
    if complement in seen {
      // Since all elements are distinct, we don't need to check seen[complement] != i
      result := (seen[complement], i);
      return;
    }
    
    seen := seen[nums[i] := i];
  }
  
  // If we reach here, no solution was found
  result := (-1, -1);
}

// Example usage
method Main() {
  var nums := new int[5];
  nums[0] := 2;
  nums[1] := 3;
  nums[2] := 4;
  nums[3] := 5;
  nums[4] := 6;
  
  var target := 8;
  var result := TwoSum(nums, target);
  
  print "Indices: ", result.0, ", ", result.1, "\n";
  if result.0 != -1 && result.1 != -1 {
    print "Values: ", nums[result.0], " + ", nums[result.1], " = ", target, "\n";
  } else {
    print "No solution found\n";
  }
}