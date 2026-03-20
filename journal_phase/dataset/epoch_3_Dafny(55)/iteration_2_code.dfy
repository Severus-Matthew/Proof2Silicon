class Node {
  var data: int
  var next: Node?
  
  ghost var a: seq<int>
  
  constructor Init(d: int, n: Node?)
    ensures Valid()
  {
    data := d;
    next := n;
    a := [d];
    if n != null {
      a := a + n.a;
    }
  }
  
  predicate Valid()
    reads this
  {
    && a == [data] + (if next != null then next.a else [])
  }
  
  method ToArray() returns (arr: array<int>)
    requires Valid()
    ensures arr.Length == |a|
    ensures forall i | 0 <= i < arr.Length :: arr[i] == a[i]
    ensures ghost var arr_a: seq<int> := arr[..]; arr_a == a
  {
    var length := |a|;
    arr := new int[length];
    
    var current: Node? := this;
    var index := 0;
    
    while index < length
      invariant 0 <= index <= length
      invariant current != null ==> current.Valid()
      invariant forall j | 0 <= j < index :: arr[j] == a[j]
      invariant ghost var prefix: seq<int> := arr[0..index]; prefix == a[0..index]
      invariant current != null ==> current.a == a[index..]
      decreases length - index
    {
      var node := current;
      arr[index] := node.data;
      
      // Ghost assertion to help verifier
      ghost var current_a := node.a;
      assert arr[index] == current_a[0];
      assert a[index] == current_a[0];
      
      current := node.next;
      index := index + 1;
    }
    
    // Final ghost assertion to ensure complete match
    ghost var full_array := arr[..];
    assert full_array == a;
  }
}

method Main() {
  var n3 := new Node.Init(3, null);
  var n2 := new Node.Init(2, n3);
  var n1 := new Node.Init(1, n2);
  
  var arr := n1.ToArray();
  print "Array: ";
  var i := 0;
  while i < arr.Length {
    print arr[i], " ";
    i := i + 1;
  }
  print "\n";
  
  // Verification checks
  assert arr.Length == 3;
  assert arr[0] == 1 && arr[1] == 2 && arr[2] == 3;
}