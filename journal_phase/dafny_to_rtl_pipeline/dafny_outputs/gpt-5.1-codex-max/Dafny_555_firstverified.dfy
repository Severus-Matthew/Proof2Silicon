module SeqSumGuide {

  method PrintSeqSumInstructions() 
  {
    print "1. Initialize an accumulator variable 'sum' to 0 using 'var sum := 0;'.\n";
    print "2. Initialize an index variable 'i' to 0 using 'var i := 0;'.\n";
    print "3. Use a while loop to traverse the sequence 's':\n";
    print "   while i < |s|\n";
    print "     invariant 0 <= i <= |s|\n";
    print "     invariant sum == (if i == 0 then 0 else the accumulated sum of s[0..i-1])\n";
    print "   {\n";
    print "     // Add the current element to the running total\n";
    print "     sum := sum + s[i];\n";
    print "     // Move to the next index\n";
    print "     i := i + 1;\n";
    print "   }\n";
    print "4. After the loop, 'sum' holds the sum of all elements in 's', so return 'sum'.\n";
    print "5. Avoid recursion in the code to implement 'seq_sum'.\n";
    print "6. Avoid recursion in the code to implement 'seq_sum'.\n";
    print "7. Avoid recursion in the code to implement 'seq_sum'.\n";
    print "8. Avoid recursion in the code to implement 'seq_sum'.\n";
    print "9. Avoid recursion in the code to implement 'seq_sum'.\n";
    print "10. Avoid recursion in the code to implement 'seq_sum'.\n";
  }
}
