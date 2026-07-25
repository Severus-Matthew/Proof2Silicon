module GeneratedStepsProgram {

  // A small helper to keep arithmetic facts explicit
  lemma IncByOne(x: int)
    ensures x + 1 > x
  {
  }

  method ExecuteSteps() returns (result: int)
    ensures result == 15
  {
    var step1 := 1;
    assert step1 == 1;

    var step2 := step1 + 1;
    assert step2 == 2;

    var step3 := step2 + 1;
    assert step3 == 3;

    var step4 := step3 + 1;
    assert step4 == 4;

    var step5 := step4 + 1;
    assert step5 == 5;

    var step6 := step5 + 1;
    assert step6 == 6;

    var step7 := step6 + 1;
    assert step7 == 7;

    var step8 := step7 + 1;
    assert step8 == 8;

    var step9 := step8 + 1;
    assert step9 == 9;

    var step10 := step9 + 1;
    assert step10 == 10;

    var step11 := step10 + 1;
    assert step11 == 11;

    var step12 := step11 + 1;
    assert step12 == 12;

    var step13 := step12 + 1;
    assert step13 == 13;

    var step14 := step13 + 1;
    assert step14 == 14;

    var step15 := step14 + 1;
    assert step15 == 15;

    result := step15;
  }

  method ExecuteStepsWithLoop() returns (result: int)
    ensures result == 15
  {
    var i := 0;
    var acc := 0;

    while i < 15
      invariant 0 <= i <= 15
      invariant acc == i
      decreases 15 - i
    {
      IncByOne(acc);
      acc := acc + 1;
      i := i + 1;
    }

    assert i == 15;
    assert acc == 15;
    result := acc;
  }
}
