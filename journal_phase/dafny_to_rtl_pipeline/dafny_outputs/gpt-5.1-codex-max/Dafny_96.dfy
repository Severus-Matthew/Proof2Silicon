module TwoSum {

  method twoSum(nums: array<int>, target: int) returns (sum1: int, sum2: int)
    requires 0 <= target <= 1000
    ensures  (sum1 == -1 && sum2 == -1)
             ==> (forall i, j :: 0 <= i < j < nums.Length ==> nums[i] + nums[j] != target)
    ensures  (sum1 == -1 && sum2 == -1)
          || (0 <= sum1 < sum2 < nums.Length && nums[sum1] + nums[sum2] == target)
    ensures 0 <= target <= 1000
  {
    var m: map<int,int> := map[];
    var i := 0;
    while i < nums.Length
      invariant 0 <= i <= nums.Length
      invariant (forall k :: k in m ==> 0 <= m[k] < i && nums[m[k]] == k)
      invariant (forall a :: 0 <= a < i ==> nums[a] in m)
      invariant (forall a, b :: 0 <= a < b < i ==> nums[a] + nums[b] != target)
      decreases nums.Length - i
    {
      var complement := target - nums[i];
      if complement in m {
        sum1 := m[complement];
        sum2 := i;
        return;
      }
      // Since complement is not in the map of previously seen values, no earlier index forms a valid pair with i
      assert (forall a :: 0 <= a < i ==> nums[a] + nums[i] != target);

      m := m[nums[i] := i];
      i := i + 1;
    }
    sum1 := -1;
    sum2 := -1;
  }

}
