module com.test {
  type T
  
  class ArrayWrapper<T> {
    var a: array<T>
    
    constructor(xs: seq<T>) 
      ensures a.Length == |xs|
      ensures fresh(a)
      ensures forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
    {
      a := new T[|xs|];
      // Use array initializer to copy without explicit iteration
      a := array(|xs|, i requires 0 <= i < |xs| => xs[i]);
    }
    
    method ToArray(xs: seq<T>) returns (a: array<T>)
      ensures fresh(a)
      ensures a.Length == |xs|
      ensures forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
    {
      a := new T[|xs|];
      // Initialize array using comprehension-style syntax
      a := array(|xs|, i requires 0 <= i < |xs| => xs[i]);
    }
  }
  
  explicit interface HelloWorld {
    method toArray(xs: seq<T>) returns (a: array<T>)
      ensures fresh(a)
      ensures a.Length == |xs|
      ensures forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
  }
  
  class HelloWorldImpl extends HelloWorld {
    method toArray(xs: seq<T>) returns (a: array<T>)
      ensures fresh(a)
      ensures a.Length == |xs|
      ensures forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
    {
      // Fresh allocation with matching length
      a := new T[|xs|];
      
      // Use array initializer with lambda to avoid explicit iteration
      a := array(|xs|, i requires 0 <= i < |xs| => xs[i]);
    }
  }
  
  // Helper lemma for verification
  lemma SequenceArrayEquality(xs: seq<T>, a: array<T>)
    requires a.Length == |xs|
    requires forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
    ensures forall i :: 0 <= i < a.Length ==> a[i] == xs[i]
  {
  }
  
  // Main verification method
  method Main() {
    var xs: seq<int> := [1, 2, 3];
    var impl := new HelloWorldImpl();
    var result := impl.toArray(xs);
    
    // Verification checks
    assert fresh(result);
    assert result.Length == 3;
    assert result[0] == 1;
    assert result[1] == 2;
    assert result[2] == 3;
  }
}