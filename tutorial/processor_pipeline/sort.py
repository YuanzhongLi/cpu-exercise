map = {
  '0': 0,
  '1': 1,
  '2': 2,
  '3': 3,
  '4': 4,
  '5': 5,
  '6': 6,
  '7': 7,
  '8': 8,
  '9': 9,
  'a': 10,
  'b': 11,
  'c': 12,
  'd': 13,
  'e': 14,
  'f': 15
}

map2 = {
  10: 'a',
  11: 'b',
  12: 'c',
  13: 'd',
  14: 'e',
  15: 'f'
}

def POW(x, n):
  ret = 1
  while (n):
    if (n&1):
      ret *= x
    x *= x
    n >>= 1
  return ret

def hexStr2int(str):
  global map
  ret = 0
  for i in range(len(str)):
    ret += POW(16, i) * int(map[str[len(str)-1-i]])
  return ret

def int2StrBinary(x, bitLength = 16):
  a = [0 for _ in range(16)]
  idx = bitLength-1
  while (x):
    a[idx] = (x&1)
    x >>= 1
    idx -= 1

  ret = ''
  for bit in a:
    ret += str(bit)
  return ret

def int2StrHex(x):
  ret = ''
  while (x):
    tmp = x % 16
    if tmp > 9:
      ret += map2[tmp]
    else:
      ret += str(tmp)
    x //= 16
  return ret[::-1]

file_path = 'sort_data.dat'

with open(file_path, mode='r') as f:
    data = []
    lines = f.readlines()
    for line in lines:
        data.append(hexStr2int(line.rstrip()))

data.sort()

with open('sorted_data.dat', mode='w') as f:
  for d in data:
    f.writelines(str(d)+'\n')

with open('sorted_data_binary.dat', mode='w') as f:
  for d in data:
    f.writelines(int2StrBinary(d)+'\n')

with open('sorted_data_hex.dat', mode='w') as f:
  for d in data:
    f.writelines(int2StrHex(d)+'\n')
