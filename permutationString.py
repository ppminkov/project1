def toString(List):
    return ''.join(List)

def permute(input, start, end):
    if start == end:
        print toString(input)
    else:
        for i in xrange(start, end+1):
            input[start], input[i] = input[i], input[start]
            permute(input, start+1, end)
            input[start], input[i] = input[i], input[start]

input = 'ABCD'
inputLen = len(input)
inputList = list(input)
permute(inputList, 0, inputLen-1)