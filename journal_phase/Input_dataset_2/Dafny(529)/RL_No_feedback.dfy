method ReadFileAndProcessLines(filename: string) returns (result: seq<string>)
  requires filename != ""
  ensures |result| > 0
{
  // For large files, we simulate reading in chunks
  // In real implementation, this would use System.IO with buffered reading
  
  // Simulate file content as a large sequence
  var fileContent: seq<string> := ["line1", "line2", "line3", "line4", "line5", "line6"];
  var chunkSize: int := 2; // Process 2 lines at a time
  var lines: seq<string> := [];
  var index: int := 0;
  
  // Process file in chunks for efficiency
  while index < |fileContent|
    invariant 0 <= index <= |fileContent|
    invariant |lines| == index
    invariant lines == fileContent[..index]
  {
    // Determine how many lines to process in this chunk
    var remaining: int := |fileContent| - index;
    var processCount: int := if remaining < chunkSize then remaining else chunkSize;
    
    // Process chunk
    var chunkIndex: int := 0;
    while chunkIndex < processCount
      invariant 0 <= chunkIndex <= processCount
      invariant |lines| == index + chunkIndex
      invariant lines == fileContent[..(index + chunkIndex)]
    {
      var line: string := fileContent[index + chunkIndex];
      lines := lines + [line];
      chunkIndex := chunkIndex + 1;
    }
    
    // Move to next chunk
    index := index + processCount;
  }
  
  result := lines;
  
  // Postcondition check - ensure we have at least one line
  assert |result| > 0;
}

// Helper function to find minimum of two integers
function min(a: int, b: int): int
{
  if a < b then a else b
}

// Alternative function-based approach for better reusability
function ProcessFileInChunks(fileContent: seq<string>, chunkSize: int): seq<string>
  requires chunkSize > 0
  ensures |ProcessFileInChunks(fileContent, chunkSize)| == |fileContent|
  ensures |fileContent| > 0 ==> |ProcessFileInChunks(fileContent, chunkSize)| > 0
{
  if |fileContent| == 0 then
    []
  else
    var firstChunk: seq<string> := fileContent[..min(chunkSize, |fileContent|)];
    var rest: seq<string> := fileContent[min(chunkSize, |fileContent|)..];
    firstChunk + ProcessFileInChunks(rest, chunkSize)
}