class MainData {
  var maxSum: int
  
  // Constructor
  constructor()
    ensures maxSum == 0
  {
    maxSum := 0;
  }
  
  // Helper function to calculate sum
  function Sum(x: int, y: int): int
  {
    x + y
  }
  
  // Helper function to calculate maximum
  function Max(a: int, b: int): int
  {
    if a > b then a else b
  }
  
  // Method to calculate sum and update maxSum
  method CalculateSum(x: int, y: int) returns (sum: int)
    ensures sum == x + y
    ensures maxSum == old(maxSum) || maxSum == Max(old(maxSum), x + y)
    ensures maxSum >= old(maxSum)
  {
    sum := x + y;
    
    // Update maxSum if current sum is greater
    if sum > maxSum {
      maxSum := sum;
    }
  }
  
  // Method to get current maximum sum
  method GetMaxSum() returns (result: int)
    ensures result == maxSum
  {
    return maxSum;
  }
}

method Main() {
  var data := new MainData();
  var x := 5;
  var y := 3;
  
  var sum := data.CalculateSum(x, y);
  print "Sum of ", x, " and ", y, " is: ", sum, "\n";
  
  var maxSum := data.GetMaxSum();
  print "Current maximum sum is: ", maxSum, "\n";
  
  // Test with another pair
  x := 10;
  y := 7;
  sum := data.CalculateSum(x, y);
  print "Sum of ", x, " and ", y, " is: ", sum, "\n";
  
  maxSum := data.GetMaxSum();
  print "Current maximum sum is: ", maxSum, "\n";
}