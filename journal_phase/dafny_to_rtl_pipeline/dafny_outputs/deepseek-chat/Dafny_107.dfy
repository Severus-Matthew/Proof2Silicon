module CheckSumCalculator {
  class CheckSumCalculator {
    var checksum: seq<char>;

    constructor ()
      ensures checksum == []
    {
      checksum := [];
    }

    method appendChar(c: char)
      modifies this
      ensures |checksum| <= 1000000
      ensures |checksum| > 0 ==> checksum[|checksum|-1] == c
    {
      if |checksum| < 1000000 {
        checksum := checksum + [c];
      } else {
        checksum := [c];
      }
    }

    method getChecksum() returns (result: seq<char>)
      ensures result == checksum
    {
      result := checksum;
    }

    method verifyChecksum() returns (valid: bool)
      requires |checksum| <= 1000000
    {
      valid := |checksum| > 0;
    }
  }
}
