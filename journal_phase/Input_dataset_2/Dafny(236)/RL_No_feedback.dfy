method QuickSortRecursive(arr: array<int>, low: int, high: int)
  modifies arr
  requires 0 <= low <= high < arr.Length
  ensures sorted(arr, low, high + 1)
  ensures multiset(arr[low..high+1]) == old(multiset(arr[low..high+1]))
  ensures low > 0 ==> arr[low-1] == old(arr[low-1])
  ensures high < arr.Length - 1 ==> arr[high+1] == old(arr[high+1])
  decreases high - low
{
  if low < high {
    var pivotIndex := Partition(arr, low, high);
    if low < pivotIndex {
      QuickSortRecursive(arr, low, pivotIndex - 1);
    }
    if pivotIndex < high {
      QuickSortRecursive(arr, pivotIndex + 1, high);
    }
  }
}