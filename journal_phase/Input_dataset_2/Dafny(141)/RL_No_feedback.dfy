method Main() {
    var m4 := new int[3, 3];
    var r4 := new int[3, 3];
    
    // Initialize m4 with some values
    var i := 0;
    while i < 3 {
        var j := 0;
        while j < 3 {
            m4[i, j] := i * 3 + j;
            j := j + 1;
        }
        i := i + 1;
    }
    
    // Compute r4 = m4 + 1
    i := 0;
    while i < 3 {
        var j := 0;
        while j < 3 {
            r4[i, j] := m4[i, j] + 1;
            j := j + 1;
        }
        i := i + 1;
    }
    
    // Verify the assertion
    assert (forall i, j :: 0 <= i < 3 && 0 <= j < 3 ==> 
            r4[i, j] == m4[i, j] + 1);
}