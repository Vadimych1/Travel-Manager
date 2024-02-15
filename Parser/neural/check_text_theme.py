import main_cfile as main
import json

true_data = "abc"
false_data = "def"

try:
    with open("symbols.json") as f:
        symbols = json.load(f)
except:
    true_data = "abc"
    false_data = "def"

    index = 0
    symb = {}
    for i in true_data+false_data:
        if i not in symb:
            symb[index] = i
            index += 1

model = main.Model()