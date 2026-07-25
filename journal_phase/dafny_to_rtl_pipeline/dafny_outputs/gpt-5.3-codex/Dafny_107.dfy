module CheckSumCalculator {

  class CheckSumCalculator {
    var checksum: seq<char>
    const MAX_LEN: nat := 1000000

    predicate Valid()
      reads this
    {
      |checksum| <= MAX_LEN
    }

    constructor ()
      ensures checksum == []
      ensures Valid()
    {
      checksum := [];
    }

    method AppendChar(c: char) returns (result: seq<char>)
      modifies this
      ensures Valid()
      ensures result == checksum
      ensures (old(|checksum|) + 1 > MAX_LEN) ==> checksum == []
      ensures (old(|checksum|) + 1 <= MAX_LEN) ==> checksum == old(checksum) + [c]
    {
      checksum := checksum + [c];
      if |checksum| > MAX_LEN {
        checksum := [];
      }
      result := checksum;
    }

    method VerifyChecksum() returns (ok: bool)
      ensures ok <==> |checksum| <= MAX_LEN
    {
      ok := |checksum| <= MAX_LEN;
    }

    method GetChecksum() returns (result: seq<char>)
      ensures result == checksum
    {
      result := checksum;
    }

    method GetChecksumAndVerify() returns (result: seq<char>, ok: bool)
      ensures result == checksum
      ensures ok <==> |checksum| <= MAX_LEN
    {
      result := checksum;
      ok := |checksum| <= MAX_LEN;
    }

    method GetChecksumAndVerifyAndAppendChar(c: char) returns (result: seq<char>, ok: bool)
      modifies this
      ensures Valid()
      ensures result == checksum
      ensures ok <==> |checksum| <= MAX_LEN
      ensures (old(|checksum|) + 1 > MAX_LEN) ==> checksum == []
      ensures (old(|checksum|) + 1 <= MAX_LEN) ==> checksum == old(checksum) + [c]
    {
      checksum := checksum + [c];
      if |checksum| > MAX_LEN {
        checksum := [];
      }
      result := checksum;
      ok := |checksum| <= MAX_LEN;
    }
  }
}
