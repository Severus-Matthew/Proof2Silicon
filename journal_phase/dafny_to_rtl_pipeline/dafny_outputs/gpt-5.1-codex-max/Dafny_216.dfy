codatatype Stream<T> = Cons(head: T, tail: Stream<T>)

ghost method GetTwo<T>(s: Stream<T>) returns (x: T, rest: Stream<T>)
  ensures x == s.head
  ensures rest == s.tail
{
  x := s.head;
  rest := s.tail;
}

ghost method Example()
{
  // For demonstration, we assume a stream whose first element is 0 and second is 1.
  ghost var s: Stream<int>;
  assume s.head == 0;
  assume s.tail.head == 1;

  // Step-by-step reasoning about the stream
  var first, tail1 := GetTwo(s);
  assert first == 0;   // Verifies the first element

  var second, tail2 := GetTwo(tail1);
  assert second == 1;  // Verifies the second element

  // No recursion is used; we simply destruct the stream step by step.
}
