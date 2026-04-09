module Main {
  method FindSecondLargest(a: array<int>) returns (secondLargest: int)
    requires a.Length >= 2
    ensures exists i :: 0 <= i < a.Length && a[i] == secondLargest
    ensures forall j :: 0 <= j < a.Length ==> secondLargest <= a[j]
    ensures exists k :: 0 <= k < a.Length && a[k] > secondLargest || 
            (forall j :: 0 <= j < a.Length ==> a[j] == secondLargest)
  {
    // Initialize largest and secondLargest
    var largest := a[0];
    secondLargest := a[1];
    
    if largest < secondLargest {
      largest := a[1];
      secondLargest := a[0];
    } else if largest == secondLargest {
      // Find a different element if possible
      var i := 2;
      while i < a.Length && a[i] == largest
        invariant 2 <= i <= a.Length
      {
        i := i + 1;
      }
      if i < a.Length && a[i] < largest {
        secondLargest := a[i];
      }
    }
    
    // Process the rest of the array
    var i := 2;
    while i < a.Length
      invariant 2 <= i <= a.Length
      invariant largest >= secondLargest
      invariant exists j :: 0 <= j < i && a[j] == largest
      invariant exists j :: 0 <= j < i && a[j] == secondLargest
      invariant forall j :: 0 <= j < i ==> a[j] <= largest
      invariant (exists k :: 0 <= k < i && a[k] == largest && a[k] > secondLargest) ||
               (forall j :: 0 <= j < i ==> a[j] == secondLargest)
    {
      if a[i] > largest {
        secondLargest := largest;
        largest := a[i];
      } else if a[i] < largest && a[i] > secondLargest {
        secondLargest := a[i];
      } else if largest == secondLargest && a[i] < largest {
        secondLargest := a[i];
      }
      i := i + 1;
    }
  }

  method Main() {
    var a1 := new int[5][3, 5, 1, 2, 4];
    var result1 := FindSecondLargest(a1);
    print "Second largest in [3, 5, 1, 2, 4] is: ", result1, "\n";
    
    var a2 := new int[6][5, 3, 6, 2, 8, 1];
    var result2 := FindSecondLargest(a2);
    print "Second largest in [5, 3, 6, 2, 8, 1] is: ", result2, "\n";
    
    var a3 := new int[7][1, 2, 3, 4, 5, 9, 8];
    var result3 := FindSecondLargest(a3);
    print "Second largest in [1, 2, 3, 4, 5, 9, 8] is: ", result3, "\n";
    
    var a4 := new int[4][7, 7, 7, 7];
    var result4 := FindSecondLargest(a4);
    print "Second largest in [7, 7, 7, 7] is: ", result4, "\n";
    
    var a5 := new int[3][-1, -2, -3];
    var result5 := FindSecondLargest(a5);
    print "Second largest in [-1, -2, -3] is: ", result5, "\n";
  }
}