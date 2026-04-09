// Helper function to calculate the maximum value in a list
function sequenceMaxHelper(values: seq<int>): int
  requires |values| > 0
  ensures forall i :: 0 <= i < |values| ==> values[i] <= sequenceMaxHelper(values)
  ensures exists i :: 0 <= i < |values| && values[i] == sequenceMaxHelper(values)
{
  if |values| == 1 then
    values[0]
  else
    var maxOfRest := sequenceMaxHelper(values[1..]);
    if values[0] > maxOfRest then values[0] else maxOfRest
}

// Main method to compute the rolling maximum list
method main(values: seq<int>) returns (maxList: seq<int>)
  ensures |maxList| == |values| + 1
  ensures maxList[0] == 0
  ensures forall i :: 0 <= i < |values| ==> 
    maxList[i + 1] == (if values[i] > maxList[i] then values[i] else maxList[i])
  ensures |values| > 0 ==> maxList[|values|] == sequenceMaxHelper(values)
{
  maxList := [0];
  var i: nat := 0;
  
  while i < |values|
    invariant 0 <= i <= |values|
    invariant |maxList| == i + 1
    invariant maxList[0] == 0
    invariant forall j :: 0 <= j < i ==> 
      maxList[j + 1] == (if values[j] > maxList[j] then values[j] else maxList[j])
    decreases |values| - i
  {
    var currentMax := maxList[i];
    var nextMax := if values[i] > currentMax then values[i] else currentMax;
    maxList := maxList + [nextMax];
    i := i + 1;
  }
}

// Alternative implementation that matches the original specification
method rollingMax(values: seq<int>) returns (maxList: seq<int>)
  ensures |maxList| == |values| + 1
  ensures forall i :: 0 <= i < |values| ==> maxList[i] == values[i]
  ensures |values| > 0 ==> maxList[|values|] == sequenceMaxHelper(values)
  ensures |values| == 0 ==> maxList[0] == 0
{
  if |values| == 0 {
    maxList := [0];
  } else {
    maxList := values + [sequenceMaxHelper(values)];
  }
}

// Test method
method TestMain() {
  var test1: seq<int> := [1, 3, 2, 5, 4];
  var result1 := main(test1);
  print "Input: ", test1, "\n";
  print "Result (rolling max): ", result1, "\n";
  
  var test2: seq<int> := [10];
  var result2 := main(test2);
  print "Input: ", test2, "\n";
  print "Result (rolling max): ", result2, "\n";
  
  var test3: seq<int> := [];
  var result3 := main(test3);
  print "Input: ", test3, "\n";
  print "Result (rolling max): ", result3, "\n";
  
  // Test with decreasing values
  var test4: seq<int> := [5, 4, 3, 2, 1];
  var result4 := main(test4);
  print "Input (decreasing): ", test4, "\n";
  print "Result (rolling max): ", result4, "\n";
  
  // Test alternative method
  print "\nTesting alternative method:\n";
  var result5 := rollingMax(test1);
  print "Alternative for ", test1, ": ", result5, "\n";
}