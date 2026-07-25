module GeneratedStepsProgram {

  class StepState {
    var value: int
    var stepsCompleted: nat

    constructor ()
      ensures value == 0
      ensures stepsCompleted == 0
    {
      value := 0;
      stepsCompleted := 0;
    }

    predicate Valid()
      reads this
    {
      0 <= stepsCompleted <= 15
    }
  }

  method ApplyStep(s: StepState, step: nat)
    requires s != null
    requires s.Valid()
    requires 1 <= step <= 15
    requires s.stepsCompleted + 1 == step
    modifies s
    ensures s.Valid()
    ensures s.stepsCompleted == step
    ensures s.value == old(s.value) + step as int
  {
    s.value := s.value + step as int;
    s.stepsCompleted := step;
    assert s.Valid();
  }

  method ExecuteAllSteps() returns (finalValue: int, completed: nat)
    ensures completed == 15
    ensures finalValue == 120
  {
    var s := new StepState();

    // step 1
    ApplyStep(s, 1);
    // step 2
    ApplyStep(s, 2);
    // step 3
    ApplyStep(s, 3);
    // step 4
    ApplyStep(s, 4);
    // step 5
    ApplyStep(s, 5);
    // step 6
    ApplyStep(s, 6);
    // step 7
    ApplyStep(s, 7);
    // step 8
    ApplyStep(s, 8);
    // step 9
    ApplyStep(s, 9);
    // step 10
    ApplyStep(s, 10);
    // step 11
    ApplyStep(s, 11);
    // step 12
    ApplyStep(s, 12);
    // step 13
    ApplyStep(s, 13);
    // step 14
    ApplyStep(s, 14);
    // step 15
    ApplyStep(s, 15);

    completed := s.stepsCompleted;
    finalValue := s.value;

    assert completed == 15;
    assert finalValue == 120;
  }
}
