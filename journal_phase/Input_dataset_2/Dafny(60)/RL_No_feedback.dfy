method SwapSimultaneous(x: int, y: int) returns (x1: int, y1: int)
  // Postcondition: Values are swapped and no longer in original positions
  ensures x1 == y && y1 == x
  ensures x1 != x && y1 != y
{
  // Simultaneous assignment using tuple syntax
  x1, y1 := y, x;
}

method SwapUsingTemporary(a: int, b: int) returns (newA: int, newB: int)
  // Postcondition: Values are swapped and no longer in original positions
  ensures newA == b && newB == a
  ensures newA != a && newB != b
{
  // Using tuple assignment for clarity and efficiency
  newA, newB := b, a;
}

method SwapPaws(paw1: int, paw2: int) returns (newPaw1: int, newPaw2: int)
  // Postcondition: Values are swapped (paws are no longer in original positions)
  ensures newPaw1 == paw2 && newPaw2 == paw1
  ensures newPaw1 != paw1 && newPaw2 != paw2
{
  // Simultaneous swap using tuple assignment
  newPaw1, newPaw2 := paw2, paw1;
}

method FinalizedSwap(a: int, b: int, c: int, d: int) returns (newA: int, newB: int, newC: int, newD: int)
  // Postcondition: Values are swapped and no longer in original order
  ensures newA == b && newB == a
  ensures newA != a && newB != b
  ensures newC == d && newD == c
  ensures newC != c && newD != d
{
  // Using tuple assignment for a general implementation
  newA, newB := b, a;
  newC, newD := d, c;
}