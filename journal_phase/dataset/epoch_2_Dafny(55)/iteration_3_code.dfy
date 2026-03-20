method update_list(lst: array<int>, idx: int, value: int) 
  modifies lst
{
  lst[0] := lst[idx];
  lst[idx] := value;
}

function Predecessor<T>(head: T, tail: seq<T>, xs: seq<T>): T
{
  if |tail| > 0 then
    tail[0]
  else
    head
}

function Duplicate_predecessor_sequence<T>(head: T, tail: seq<T>, xs: seq<T>): seq<T>
{
  if |tail| > 0 then
    [tail[0]] + tail
  else
    [head]
}

function Forward_to_string_contracts(k: int, entity: string): string
  requires entity != ""
{
  entity
}

method Function_of_function_test(proposed_strs: seq<string>) returns (result: seq<string>)
{
  var possible_transformations: seq<string> := ["Vector_function", "pointer_function", "dict_function"];
  result := [];
  
  var i := 0;
  while i < |proposed_strs|
    invariant i <= |proposed_strs|
  {
    result := result + [proposed_strs[i]];
    i := i + 1;
  }
}

class Characterized {
  var field: int;
  
  method notionally_newly_good() returns (x: int)
  {
    x := this.field;
  }
}

method Dual_add_character_to_spec(output: string, with_suffix: string) returns (result: string)
{
  result := output + with_suffix;
}

method render_code_012210_output_type_boolean(output: bool) returns (result: bool)
{
  result := output;
}

method Claus_to_instances_to_new_tem_products(d: int, D: int, d1: int, d2: int) returns (result: int)
{
  result := d + D + d1 + d2;
}

method In_a_fashion(alpha: int, beta: int) returns (result: int)
{
  result := alpha + beta;
}

method Excluded_CodeIn() 
{
  // Empty method implementation
}

method Valid_Static_File_Handler() 
{
  // Empty method implementation
}

method AAd_i_Child(delimiter: string, place_in_file: string) 
{
  // Empty method implementation
}

method nesting_failure() 
{
  // Empty method implementation
}

method gather_contact_data(path_from: string, to: string) returns (result: string)
{
  result := path_from + " -> " + to;
}

method will_customer_would() 
{
  // Empty method implementation
}