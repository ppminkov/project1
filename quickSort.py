""" Pick an element, called a pivot, from the array.
1. Partitioning: reorder the array so that all elements with values less than the pivot come before the pivot, 
while all elements with values greater than the pivot come after it (equal values can go either way). 
2. After this partitioning, the pivot is in its final position. This is called the partition operation.
3. Recursively apply the above steps to the sub-array of elements with smaller values and 
separately to the sub-array of elements with greater values. """

def partition(arr, low, high):
    i = (low-1)         # index of the smallest element
    pivot = arr[high]   # pivot

    for j in range(low, high):
        if arr[j] <= pivot:
            i = i+1
            arr[i], arr[j] = arr[j], arr[i]
    arr[i+1], arr[high] = arr[high], arr[i+1]
    return (i+1)

def quickSort(arr, low, high):
    if low < high:
        pi = partition(arr, low, high)
        quickSort(arr, low, pi-1)
        quickSort(arr, pi+1, high)

arr = [1,2,41,3,5,1,7,9,2,55,4,3,6,54,445]
n = len(arr)
quickSort(arr, 0, n-1)
print ("Sorted array is:")
for i in range(n):
    print ("%d" %arr[i]), # , prints the numbers in one row, no comma means one under another

