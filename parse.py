import csv
import os

# функция принимает 2 пути(путь изначального файла абоненты и куда сохранить)
# рассчитывает "Начислено" в зависимости от типа начисления
# сохраняет эти данные дополнительным столбцом в файл "Начисления_абоненты.csv"
def calc_abonent_nach(infile, outfile):
    with open(infile, 'r', newline='', encoding='utf-8') as infile, \
         open('начисления.csv', 'w', newline='', encoding='utf-8') as promfile:
        reader = csv.reader(infile, delimiter=";")
        writer = csv.writer(promfile, delimiter=";")
        # добавляю новую строку со словом начислено
        for row in reader:
            row.append('Начислено')
            writer.writerow(row)
    infile.close()
    promfile.close()
    with open('начисления.csv', 'r', newline='', encoding='utf-8') as infile, \
         open(outfile, 'w', newline='', encoding='utf-8') as outfile:
        reader = csv.reader(infile, delimiter=";")
        writer = csv.writer(outfile, delimiter=";")
        # для строк считаю и записываю начисления в зависимости от типа
        for row in reader:
            if row[5] == '1':
                row[8] = '301,26'
            elif row[5] == '2':
                nach = (float(row[7]) - float(row[6])) * 1.52
                row[8] = str(nach).replace('.', ',')
            writer.writerow(row)
    infile.close()
    outfile.close()
    # удаляю промежуточный файл
    os.remove('начисления.csv')

# функция принимает путь(куда сохранить новый файл)
# считает суммарное начисление по каждому дому
# сохраняет информацию в файл "Начисления_дома.csv"
# в виде таблицы со столбцами |"№ строки | Улица | № дома | Начислено.
def calc_house_nach(outfile):
    with open(outfile, 'r', newline='', encoding='utf-8') as outfile, \
         open('Начисления_дома.csv', 'w', newline='', encoding='utf-8') as hfile:
        reader = csv.DictReader(outfile, delimiter=";", fieldnames=None)
        fieldnames = ['№ строки', 'Улица', '№ дома', 'Начислено']
        writer = csv.DictWriter(hfile, delimiter="|", fieldnames=fieldnames)
        # записываю заголовки в файл
        hfile.write('|')
        writer.writeheader()
        house_dict = {}
        # считаю начисления по адресам , записываю в словарь
        for row in reader:
            house = str(row['№ дома'])
            street = str(row['Улица'])
            nachisleno = float(row['Начислено'].replace(',', '.'))
            try:
                house_dict[street, house] += nachisleno
            except KeyError:
                house_dict[street, house] = nachisleno
        # преобразую словарь в список
        house_list = [[*key, value] for key, value in house_dict.items()]
        # добавляю номер строки
        row_num = 0
        for ellist in house_list:
            row_num += 1
            ellist.insert(0, row_num)
        # записываю в файл с разделителем
        for ellist in house_list:
            hfile.write('|')
            for el in ellist:
                el = str(el)
                hfile.write(el)
                hfile.write('|')
            hfile.write('\n')
    hfile.close()
    outfile.close()

# путь к файлу абоненты.csv
infile = 'абоненты.csv'
# путь куда сохранить Начисления_абоненты.csv и где его потом искать
outfile = 'Начисления_абоненты.csv'
calc_abonent_nach(infile, outfile)
calc_house_nach(outfile)
