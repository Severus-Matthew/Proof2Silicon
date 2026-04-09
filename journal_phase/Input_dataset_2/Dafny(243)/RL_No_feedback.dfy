method BubbleSortDescending(arr: array<int>) 
  modifies arr
  ensures forall i, j :: 0 <= i < j < arr.Length ==> arr[i] >= arr[j]
  ensures multiset(arr[..]) == multiset(old(arr[..]))
{
  var n := arr.Length;
  if (n <= 1) {
    return;
  }
  
  var i := 0;
  
  while (i < n - 1)
    invariant 0 <= i <= n - 1
    invariant forall k, l :: n - i <= k < l < n ==> arr[k] >= arr[l]  // Last i elements are sorted in descending order
    invariant forall k :: 0 <= k < n - i ==> arr[k] >= arr[n - i - 1]  // All elements before n-i are >= the element at n-i-1
    invariant multiset(arr[..]) == multiset(old(arr[..]))
    decreases n - i - 1
  {
    var j := 0;
    
    while (j < n - i - 1)
      invariant 0 <= j <= n - i - 1
      invariant forall k {:trigger arr[k]} :: 0 <= k < j ==> arr[k] >= arr[j]  // Elements before j are >= arr[j]
      invariant forall k :: j <= k < n - i - 1 ==> arr[j] >= arr[k + 1]  // arr[j] is >= all elements from j to n-i-1
      invariant forall k, l :: n - i <= k < l < n ==> arr[k] >= arr[l]  // Last i elements remain sorted
      invariant multiset(arr[..]) == multiset(old(arr[..]))
      decreases n - i - j - 1
    {
      if (arr[j] < arr[j + 1]) {
        // Swap elements
        var temp := arr[j];
        arr[j] := arr[j + 1];
        arr[j + 1] := temp;
      }
      j := j + 1;
    }
    
    i := i + 1;
  }
}

method Main() {
  var arr1 := new int[5][1, 3, 2, 5, 4];
  var arr2 := new int[5][5, 4, 3, 2, 1];
  var arr3 := new int[5][1, 2, 3, 4, 5];
  var arr4 := new int[1][42];
  var arr5 := new int[0][];
  
  print "Original array 1: ";
  PrintArray(arr1);
  BubbleSortDescending(arr1);
  print "Sorted descending: ";
  PrintArray(arr1);
  print "\n";
  
  print "Original array 2: ";
  PrintArray(arr2);
  BubbleSortDescending(arr2);
  print "Sorted descending: ";
  PrintArray(arr2);
  print "\n";
  
  print "Original array 3: ";
  PrintArray(arr3);
  BubbleSortDescending(arr3);
  print "Sorted descending: ";
  PrintArray(arr3);
  print "\n";
  
  print "Original array 4: ";
  PrintArray(arr4);
  BubbleSortDescending(arr4);
  print "Sorted descending: ";
  PrintArray(arr4);
  print "\n";
  
  print "Original array 5: ";
  PrintArray(arr5);
  BubbleSortDescending(arr5);
  print "Sorted descending: ";
  PrintArray(arr5);
}

method PrintArray(arr: array<int>) {
  var i := 0;
  while (i < arr.Length) {
    print arr[i];
    if (i < arr.Length - 1) {
      print ", ";
    }
    i := i + 1;
  }
  print "\n";
}