function AllCharactersSame(s: string): bool
{
    if |s| == 0 then true else forall i :: 0 <= i < |s| ==> s[i] == s[0]
}

method Main()
{
    var testStrings: seq<string> := ["a", "abababab", "aaabbb"];
    var results: seq<bool> := [];

    var i := 0;
    while i < |testStrings|
        invariant 0 <= i <= |testStrings|
        invariant |results| == i
        invariant forall k :: 0 <= k < i ==> results[k] == AllCharactersSame(testStrings[k])
        decreases |testStrings| - i
    {
        results := results + [AllCharactersSame(testStrings[i])];
        i := i + 1;
    }

    var j := 0;
    while j < |results|
        invariant 0 <= j <= |results|
        decreases |results| - j
    {
        if results[j] {
            // If all characters are the same, print "All characters are the same."
            print "All characters are the same.\n";
        } else {
            // If there are different characters, print "Different characters."
            print "Different characters.\n";
        }
        j := j + 1;
    }
}
