method FindLongestCommonPrefixAndSubstring(S: string, T: string) 
    returns (prefixLength: nat, substringLength: nat)
    ensures prefixLength <= |S| && prefixLength <= |T|
    ensures substringLength <= |S| && substringLength <= |T|
    // Note: prefixLength <= substringLength is NOT always true
    // Example: S="abxy", T="abz" - prefix=2, substring=0
{
    // Initialize lengths
    prefixLength := 0;
    substringLength := 0;
    
    // Find longest common prefix
    var i := 0;
    while i < |S| && i < |T| && S[i] == T[i]
        invariant i <= |S| && i <= |T|
        invariant prefixLength == i
        decreases |S| - i, |T| - i
    {
        prefixLength := prefixLength + 1;
        i := i + 1;
    }
    
    // Find longest common substring using dynamic programming approach
    // Create a 2D array for DP
    var dp := new int[|S| + 1, |T| + 1];
    
    // Initialize dp array - all zeros
    var x := 0;
    while x <= |S|
        invariant x <= |S| + 1
        invariant forall j :: 0 <= j <= |T| ==> dp[0, j] == 0
        decreases |S| + 1 - x
    {
        dp[x, 0] := 0;
        x := x + 1;
    }
    
    var y := 0;
    while y <= |T|
        invariant y <= |T| + 1
        invariant forall i :: 0 <= i <= |S| ==> dp[i, 0] == 0
        decreases |T| + 1 - y
    {
        dp[0, y] := 0;
        y := y + 1;
    }
    
    // Fill dp array to find longest common substring
    var maxLen := 0;
    x := 1;
    while x <= |S|
        invariant 1 <= x <= |S| + 1
        invariant forall i, j :: 0 <= i < x && 0 <= j <= |T| ==> 
            dp[i, j] >= 0 && dp[i, j] <= (if i < j then i else j)
        invariant maxLen >= 0 && maxLen <= (if x-1 < |T| then x-1 else |T|)
        decreases |S| + 1 - x
    {
        y := 1;
        while y <= |T|
            invariant 1 <= y <= |T| + 1
            invariant forall j :: 0 <= j < y ==> 
                dp[x, j] >= 0 && dp[x, j] <= (if x < j then x else j)
            invariant maxLen >= 0 && maxLen <= (if x-1 < y-1 then x-1 else y-1)
            decreases |T| + 1 - y
        {
            if S[x-1] == T[y-1] {
                dp[x, y] := dp[x-1, y-1] + 1;
                if dp[x, y] > maxLen {
                    maxLen := dp[x, y];
                }
            } else {
                dp[x, y] := 0;
            }
            y := y + 1;
        }
        x := x + 1;
    }
    
    substringLength := maxLen;
}