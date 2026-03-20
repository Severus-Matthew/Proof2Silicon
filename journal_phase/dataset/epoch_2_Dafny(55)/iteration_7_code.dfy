module RL_No_feedback {
  // Define a generic sequence type
  datatype SeqT<T> = Nil | Cons(head: T, tail: SeqT<T>)
  
  // Helper function to convert array to sequence
  function method FromArray<T>(arr: array<T>): SeqT<T>
    reads arr
  {
    if arr.Length == 0 then Nil
    else Cons(arr[0], FromArray(arr[1..]))
  }
  
  // Function to convert sequence to string (no null returns)
  function method ToString<T>(seq: SeqT<T>): string
  {
    match seq
    case Nil => ""
    case Cons(h, t) => 
      if t == Nil then h.ToString()
      else h.ToString() + ", " + ToString(t)
  }
  
  // Check if element is member of sequence
  predicate method IsMember<T(==)>(seq: SeqT<T>, candidate: T)
  {
    match seq
    case Nil => false
    case Cons(h, t) => h == candidate || IsMember(t, candidate)
  }
  
  // Safe array access with bounds checking
  method SafeArrayAccess<T>(arr: array<T>, index: int) returns (result: T)
    requires 0 <= index < arr.Length
    ensures result == arr[index]
  {
    result := arr[index];
  }
  
  // Implementation example with proper constraints
  method ProcessSequence(seq: SeqT<int>) returns (sum: int)
    ensures sum >= 0
  {
    sum := 0;
    var current := seq;
    
    while current != Nil
      invariant sum >= 0
    {
      match current {
        case Cons(h, t) =>
          sum := sum + h;
          current := t;
        case Nil =>
      }
    }
  }
  
  // Example usage
  method Example() {
    var arr := new int[3];
    arr[0] := 1;
    arr[1] := 2;
    arr[2] := 3;
    
    var seq := FromArray(arr);
    var str := ToString(seq);
    var hasTwo := IsMember(seq, 2);
    var sum := ProcessSequence(seq);
    
    print "Sequence: " + str + "\n";
    print "Contains 2: " + hasTwo + "\n";
    print "Sum: " + sum + "\n";
  }
}