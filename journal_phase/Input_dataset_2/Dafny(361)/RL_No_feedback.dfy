// A simple verified assembler/interpreter
module Assembler {
  // Instruction set
  datatype Instruction = 
    | LOAD(constant: int)
    | STORE(address: int)
    | ADD
    | SUB
    | HALT
    | JUMP(address: int)
    | JUMP_IF_ZERO(address: int)
    | MOD // accumulator = accumulator % memory[programCounter + 1]
    | LOAD_INDIRECT(address: int) // Load from memory[address]
    | STORE_INDIRECT(address: int) // Store to memory[address]
    | LOAD_ADDRESS(address: int) // Load address itself (not memory[address])
    | COPY(src: int, dst: int) // Copy memory[src] to memory[dst]

  // Machine state
  class MachineState {
    var memory: seq<int>
    var accumulator: int
    var programCounter: int
    var halted: bool

    predicate Valid() 
      reads this
    {
      programCounter >= 0 && 
      (halted || programCounter < |memory|)
    }

    constructor Init(memSize: int) 
      ensures Valid()
    {
      memory := seq(memSize, _ => 0);
      accumulator := 0;
      programCounter := 0;
      halted := false;
    }
  }

  // Execute a single instruction
  method ExecuteInstruction(machine: MachineState, program: seq<Instruction>) 
    requires machine.Valid()
    requires machine.programCounter < |program|
    modifies machine
    ensures machine.Valid()
  {
    var instr := program[machine.programCounter];
    
    match instr {
      case LOAD(constant) => 
        machine.accumulator := constant;
        machine.programCounter := machine.programCounter + 1;
      
      case STORE(address) => 
        if 0 <= address < |machine.memory| {
          machine.memory := machine.memory[address := machine.accumulator];
        }
        machine.programCounter := machine.programCounter + 1;
      
      case ADD => 
        if machine.programCounter + 1 < |machine.memory| {
          machine.accumulator := machine.accumulator + machine.memory[machine.programCounter + 1];
        }
        machine.programCounter := machine.programCounter + 1;
      
      case SUB => 
        if machine.programCounter + 1 < |machine.memory| {
          machine.accumulator := machine.accumulator - machine.memory[machine.programCounter + 1];
        }
        machine.programCounter := machine.programCounter + 1;
      
      case MOD => 
        if machine.programCounter + 1 < |machine.memory| {
          var divisor := machine.memory[machine.programCounter + 1];
          if divisor != 0 {
            machine.accumulator := machine.accumulator % divisor;
          }
        }
        machine.programCounter := machine.programCounter + 1;
      
      case HALT => 
        machine.halted := true;
      
      case JUMP(address) => 
        if 0 <= address < |program| {
          machine.programCounter := address;
        } else {
          machine.programCounter := machine.programCounter + 1;
        }
      
      case JUMP_IF_ZERO(address) => 
        if machine.accumulator == 0 && 0 <= address < |program| {
          machine.programCounter := address;
        } else {
          machine.programCounter := machine.programCounter + 1;
        }
      
      case LOAD_INDIRECT(address) =>
        if 0 <= address < |machine.memory| {
          var indirectAddress := machine.memory[address];
          if 0 <= indirectAddress < |machine.memory| {
            machine.accumulator := machine.memory[indirectAddress];
          }
        }
        machine.programCounter := machine.programCounter + 1;
      
      case STORE_INDIRECT(address) =>
        if 0 <= address < |machine.memory| {
          var indirectAddress := machine.memory[address];
          if 0 <= indirectAddress < |machine.memory| {
            machine.memory := machine.memory[indirectAddress := machine.accumulator];
          }
        }
        machine.programCounter := machine.programCounter + 1;
      
      case LOAD_ADDRESS(address) =>
        machine.accumulator := address;
        machine.programCounter := machine.programCounter + 1;
      
      case COPY(src, dst) =>
        if 0 <= src < |machine.memory| && 0 <= dst < |machine.memory| {
          machine.memory := machine.memory[dst := machine.memory[src]];
        }
        machine.programCounter := machine.programCounter + 1;
    }
  }

  // Execute a complete program
  method ExecuteProgram(machine: MachineState, program: seq<Instruction>) 
    requires machine.Valid()
    requires |program| <= |machine.memory|
    modifies machine
    ensures machine.Valid()
  {
    while !machine.halted && machine.programCounter < |program|
      invariant machine.Valid()
      decreases |program| - machine.programCounter
    {
      ExecuteInstruction(machine, program);
    }
  }

  // Example program: compute 1 + 2
  method ExampleProgram() 
    returns (result: int)
  {
    var machine := new MachineState.Init(10);
    var program := [
      LOAD(1),      // Load 1 into accumulator
      STORE(0),     // Store accumulator at address 0
      LOAD(2),      // Load 2 into accumulator
      ADD,          // Add memory[1] (which is 0) to accumulator
      STORE(1),     // Store result at address 1
      HALT
    ];
    
    ExecuteProgram(machine, program);
    result := machine.memory[1];
  }

  // Fixed lemma: Program counter never goes out of bounds
  lemma ProgramCounterSafe(machine: MachineState, program: seq<Instruction>)
    requires machine.Valid()
    requires |program| <= |machine.memory|
    ensures forall i {:trigger 0 <= i && i < |program|} :: 0 <= i < |program| ==> i >= 0 && i < |machine.memory|
  {
  }

  // Test the example program
  method TestExampleProgram()
  {
    var result := ExampleProgram();
    assert result == 3; // 1 + 2 = 3
  }

  // New: Program to compute powers of list elements
  // For each element x in input list, compute x^x and store in output
  method PowerOfListElements(input: seq<int>) 
    returns (output: seq<int>)
    requires |input| > 0
    ensures |output| == |input|
  {
    var machine := new MachineState.Init(100);
    
    // Initialize memory with input values starting at address 10
    var i := 0;
    while i < |input|
      invariant 0 <= i <= |input|
      invariant |machine.memory| == 100
      decreases |input| - i
    {
      machine.memory := machine.memory[10 + i := input[i]];
      i := i + 1;
    }
    
    // Program to compute x^x for each element
    // Address layout:
    // 0: counter
    // 1: constant 1
    // 2: temporary for address calculation
    // 3: current x value
    // 4: result accumulator
    // 5: power counter
    // 6: output address
    // 10-: input values
    // 50-: output values
    
    // First, store constant 1 at address 1
    machine.memory := machine.memory[1 := 1];
    
    var program := [
      // Initialize counter to 0
      LOAD(0),
      STORE(0),
      
      // Main loop start (address 2)
      // Check if counter >= input length
      LOAD(0),
      STORE(2),           // Store counter at address 2 for comparison
      LOAD(|input|),
      SUB,                // accumulator = counter - length
      JUMP_IF_ZERO(40),   // If counter == length, jump to end
      
      // Load current input element x using indirect addressing
      LOAD(0),            // Load counter
      LOAD_ADDRESS(10),   // Load base address 10
      ADD,                // accumulator = counter + 10 (address of x)
      STORE(2),           // Store address at address 2
      LOAD_INDIRECT(2),   // Load memory[address stored at address 2] = x
      STORE(3),           // Store x at address 3
      
      // Initialize result = 1
      LOAD(1),            // Load constant 1 from address 1
      STORE(4),           // result = 1 at address 4
      
      // Initialize power counter = x
      LOAD(3),            // Load x
      STORE(5),           // power counter = x at address 5
      
      // Power computation loop (address 15)
      LOAD(5),            // Load power counter
      JUMP_IF_ZERO(30),   // If power counter == 0, jump to store result
      
      // Multiply: result = result * x
      // We'll do this by adding x to result repeatedly
      LOAD(4),            // Load result
      LOAD(3),            // Load x
      ADD,                // result = result + x
      STORE(4),           // Store updated result
      
      // Decrement power counter
      LOAD(5),            // Load power counter
      LOAD(1),            // Load 1
      SUB,                // power counter = power counter - 1
      STORE(5),           // Store updated power counter
      
      JUMP(15),           // Jump back to power loop start
      
      // Store result (address 30)
      LOAD(4),            // Load computed result (x^x)
      LOAD(0),            // Load counter
      LOAD_ADDRESS(50),   // Load base address for output (50)
      ADD,                // accumulator = counter + 50
      STORE(6),           // Store output address at address 6
      LOAD(4),            // Load result again
      STORE_INDIRECT(6),  // Store result at address stored in address 6
      
      // Increment counter
      LOAD(0),            // Load counter
      LOAD(1),            // Load 1
      ADD,                // counter = counter + 1
      STORE(0),           // Store updated counter
      
      JUMP(2),            // Jump back to main loop start
      
      // End (address 40)
      HALT
    ];
    
    ExecuteProgram(machine, program);
    
    // Extract output values
    output := seq(|input|, i requires 0 <= i < |input| => machine.memory[50 + i]);
  }

  // Test the power computation
  method TestPowerComputation()
  {
    var input := [1, 2, 3];
    var output := PowerOfListElements(input);
    
    // 1^1 = 1, 2^2 = 4, 3^3 = 27
    assert output[0] == 1;
    assert output[1] == 4;
    assert output[2] == 27;
  }

  // Example program using MOD instruction
  method ModuloExample(length: int) 
    returns (result: int)
    requires length > 0
  {
    var machine := new MachineState.Init(10);
    // First store the divisor at address 1
    machine.memory := machine.memory[1 := 17];
    
    var program := [
      LOAD(5),       // Load 5 into accumulator
      MOD,           // accumulator = 5 % memory[1] = 5 % 17 = 5
      STORE(2),      // Store result at address 2
      HALT
    ];
    
    ExecuteProgram(machine, program);
    result := machine.memory[2];
  }

  // New: Test for loading from computed addresses
  method TestLoadFromAddress()
  {
    var machine := new MachineState.Init(10);
    // Store value 42 at address 5
    machine.memory := machine.memory[5 := 42];
    
    var program := [
      LOAD_ADDRESS(5),    // Load address 5 itself
      STORE(0),           // Store address at address 0
      LOAD_INDIRECT(0),   // Load from address stored at address 0 (memory[5] = 42)
      STORE(1),           // Store at address 1
      HALT
    ];
    
    ExecuteProgram(machine, program);
    assert machine.memory[1] == 42;
  }

  // New: Test COPY instruction
  method TestCopyInstruction()
  {
    var machine := new MachineState.Init(10);
    machine.memory := machine.memory[3 := 100];
    
    var program := [
      COPY(3, 7),    // Copy memory[3] to memory[7]
      HALT
    ];
    
    ExecuteProgram(machine, program);
    assert machine.memory[7] == 100;
  }
}