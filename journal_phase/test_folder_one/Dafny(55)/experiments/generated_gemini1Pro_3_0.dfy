//Dafny Code
method ToArray<T>(seq: seq<T>) returns (arr: array<T>)
  requires seq != null
  ensures arr.Length == seq.Count
  ensures forall i in 0..seq.Count-1: arr[i] == seq[i]
{
  var arr := new array<T>(seq.Count);
  for i in 0..seq.Count-1
    arr[i] := seq[i];
  return arr;
}