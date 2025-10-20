def merge(nums1, m, nums2, n):
    i = m - 1
    j = n - 1
    k = m + n - 1

    # merge from the end
    while i >= 0 and j >= 0:
        if nums1[i] > nums2[j]:
            nums1[k] = nums1[i]
            i -= 1
        else:
            nums1[k] = nums2[j]
            j -= 1
        k -= 1

    # copy remaining elements from nums2
    while j >= 0:
        nums1[k] = nums2[j]
        j -= 1
        k -= 1


# get input from user
nums1 = list(map(int, input("Enter nums1 (with zeros): ").split()))
m = int(input("Enter m: "))
nums2 = list(map(int, input("Enter nums2: ").split()))
n = int(input("Enter n: "))

merge(nums1, m, nums2, n)

print("Merged array:", nums1)
