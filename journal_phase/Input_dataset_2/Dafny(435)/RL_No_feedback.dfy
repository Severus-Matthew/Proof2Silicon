lemma common_substring_length<T>(a: seq<T>, b: seq<T>)
  requires |a| > 0 && |b| > 0
  requires exists x :: x in a && x in b
  ensures exists i, j, l {:trigger a[i..i+l]} :: 
    0 <= i && i + l <= |a| && 
    0 <= j && j + l <= |b| && 
    l > 0 && 
    a[i..i+l] == b[j..j+l]
{
  // Choose a common element that exists by precondition
  var common_elem :| common_elem in a && common_elem in b;
  
  // Find its position in a
  var i :| 0 <= i < |a| && a[i] == common_elem;
  
  // Find its position in b  
  var j :| 0 <= j < |b| && b[j] == common_elem;
  
  // The common substring of length 1 exists
  var l := 1;
  
  // Verify the postcondition
  assert 0 <= i && i + l <= |a|;
  assert 0 <= j && j + l <= |b|;
  assert l > 0;
  assert a[i..i+l] == [common_elem];
  assert b[j..j+l] == [common_elem];
  assert a[i..i+l] == b[j..j+l];
  
  // The witness for the existential quantifier
  // Note: We only need one trigger since a[i..i+l] == b[j..j+l] implies both
  assert exists i, j, l :: 
    0 <= i && i + l <= |a| && 
    0 <= j && j + l <= |b| && 
    l > 0 && 
    a[i..i+l] == b[j..j+l];
}