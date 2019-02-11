# # compares each pair of adjacent items and swaps them if they are in the wrong order
# def bubbleSort(arr):
#     n = len(arr)
#     for i in range(n):
#         for j in range(0, n-i-1):
#             if arr[j] > arr[j+1]: 
#                 arr[j], arr[j+1] = arr[j+1], arr[j]

def bubbleSort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n-i-1):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]


#arr = [64, 34, 25, 12, 22, 11, 90]
#bubbleSort(arr)

""" print ("Sorted array :")
for i in range(len(arr)):
	print ("%d" %arr[i]),
"""

arr = [9,12,3,2,3,4]
bubbleSort(arr)





for i in range(len(arr)):  
    print ("%d" %arr[i]),