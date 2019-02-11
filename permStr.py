def toString(List):
    return ''.join(List)


# Function to print all permutation of a string
# The function takes three params: string, start/end index
def permute(a, l, r):
    if l==r:
        print toString(a)
    else: 
        for i in xrange(l,r+1):
            a[l], a[i] = a[i], a[l]
            permute(a, l+1, r)
            a[l], a[i] = a[i], a[l]

string = "ABCD"
n = len(string)
a = list(string)
permute(a, 0, n-1)