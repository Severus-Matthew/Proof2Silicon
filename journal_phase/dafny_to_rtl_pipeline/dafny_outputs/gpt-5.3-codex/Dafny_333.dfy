module Lowercase {

  // True iff c is an ASCII uppercase letter.
  predicate IsUpper(c: char)
  {
    'A' <= c <= 'Z'
  }

  // Maps an uppercase ASCII letter to its lowercase counterpart.
  function ToLowerChar(c: char): char
    requires IsUpper(c)
    ensures ToLowerChar(c) == (c as int + 32) as char
  {
    (c as int + 32) as char
  }

  // Checks whether all characters in s are not uppercase ASCII letters.
  predicate IsLowercaseOrNonLetters(s: string)
  {
    forall i :: 0 <= i < |s| ==> !IsUpper(s[i])
  }

  // Returns a new string where every uppercase ASCII letter is converted to lowercase.
  method ToLowercase(s: string) returns (t: string)
    ensures |t| == |s|
    ensures forall i :: 0 <= i < |s| ==>
              (if IsUpper(s[i]) then t[i] == ToLowerChar(s[i]) else t[i] == s[i])
    ensures IsLowercaseOrNonLetters(t)
  {
    var i: int := 0;
    t := "";
    while i < |s|
      invariant 0 <= i <= |s|
      invariant |t| == i
      invariant forall j :: 0 <= j < i ==>
                (if IsUpper(s[j]) then t[j] == ToLowerChar(s[j]) else t[j] == s[j])
      invariant IsLowercaseOrNonLetters(t)
      decreases |s| - i
    {
      if IsUpper(s[i]) {
        t := t + [ToLowerChar(s[i])];
      } else {
        t := t + [s[i]];
      }
      i := i + 1;
    }
    return t;
  }

  // Checks whether the method correctly converts uppercase letters to lowercase.
  method Check(s: string) returns (result: bool)
    ensures result == true
  {
    var t := ToLowercase(s);
    assert |t| == |s|;
    assert forall i :: 0 <= i < |s| ==>
             (if IsUpper(s[i]) then t[i] == ToLowerChar(s[i]) else t[i] == s[i]);
    assert IsLowercaseOrNonLetters(t);
    result := true;
  }
}
