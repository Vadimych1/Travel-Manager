import main_cfile as main
import random

true_data = ""
false_data = ""

symbols_size = 256

with open("true_data.txt") as f:
    true_data = f.read()

with open("false_data.txt") as f:
    false_data = f.read()

index = 0
symb = {}
for i in (true_data+false_data):
    if not (i in symb):
        symb[i] = index
        index += 1

# Create batches in <symbols_size> symbol length
def create_batches(data: str, symbols_size: int, symb: dict = {}) -> list:
    batches = []
    print(symb)

    for i in range(0, len(data) - symbols_size, symbols_size):
        try:
            l = [symb[d] for d in data[i : i + symbols_size]]
        except:
            print("SKIP")
            continue

        if len(l) < symbols_size:
            continue

        batches.append(l)

    return batches

true = create_batches(true_data, symbols_size, symb)
false = create_batches(false_data, symbols_size, symb)

true = [[i, [1, 0]] for i in true]
false = [[i, [0, 1]] for i in false]

data = true + false
random.shuffle(data)

model = main.Model()
model.fit(x_data=[i[0] for i in data], y_data=[i[1] for i in data], epochs=5000)
model.save()