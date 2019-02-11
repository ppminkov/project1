def factorial(n):
    if n == 0:
        return 1
    else:
        return n * factorial(n-1)

f = 5
print "Factorial of " + str(f) + " is:" + str(factorial(f))