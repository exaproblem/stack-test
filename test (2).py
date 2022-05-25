# есть последовательность с заранее неизвестным количеством произвольных букв
# необходимо написать функцию, группирующую части последовательности по типу символа:
# Пример:
# имеется строка aaabbbbccddaaabb
# Результат работы:
# aaaaaa
# bbbbbb
# cc
# dd
input = 'aaabbbbccddaaabb'
dict = {}
for el in input:
    perem = el
    raz = 0
    for el in input:
        if el == perem:
            raz += 1
    dict [perem] = raz
# print(dict)
for key,value in dict.items():
    it = value
    while it > 0:
        print(key, end="")
        it -= 1
    print('')