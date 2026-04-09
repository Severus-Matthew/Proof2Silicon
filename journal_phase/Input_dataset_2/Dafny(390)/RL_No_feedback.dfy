method CustomLeftRotation(num: bv32, rotateCount: int) returns (result: bv32)
  requires 0 <= rotateCount < 32
  ensures result == (num << rotateCount) | (num >> (32 - rotateCount))
{
  if rotateCount == 0 {
    result := num;
  } else {
    var shiftedPart: bv32 := num << rotateCount;
    var rightShiftedPart: bv32 := num >> (32 - rotateCount);
    result := shiftedPart | rightShiftedPart;
  }
}