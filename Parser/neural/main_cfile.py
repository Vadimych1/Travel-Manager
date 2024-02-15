from keras import Sequential
import keras
from keras.layers import Dense, Dropout, Embedding, Flatten, Conv1D, MaxPooling1D
from keras.activations import relu, sigmoid
from keras.models import load_model
from keras.losses import binary_crossentropy
from keras.optimizers import Adam
from keras.metrics import Accuracy, Precision, Recall

class Model:
    def __init__(self, textInputSize: int | None = 256, maxSymbNum: int | None = 256):
        try:
            self.model = load_model("model.h5")
        except:
            self.model = Sequential([
                Embedding(maxSymbNum, 32, input_length=textInputSize),
                Conv1D(32, 3, activation=relu),
                MaxPooling1D(),
                Conv1D(32, 3, activation=relu),
                MaxPooling1D(),
                Conv1D(32, 3, activation=relu),
                MaxPooling1D(),
                Flatten(),
                Dense(128, activation=relu),
                Dense(2, activation=sigmoid)
            ])

            self.model.compile(optimizer=Adam(learning_rate=0.001), loss="categorical_crossentropy", metrics=[Accuracy(), Precision(), Recall()])

    def save(self):
        self.model.save("model.h5")

    def predict(self, text_indexes: list):
        return self.model.predict(text_indexes)
    
    def fit(self, x_data: list, y_data: list, epochs: int = 100):
        self.model.fit(x_data, y_data, epochs=epochs)