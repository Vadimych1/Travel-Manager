from keras import Sequential
import keras
from keras.layers import Dense, Dropout, Embedding, Flatten, Conv1D, MaxPooling1D
from keras.activations import relu, sigmoid
from keras.models import load_model
from keras.losses import binary_crossentropy
from keras.optimizers import Adam
from keras.metrics import Accuracy, Precision, Recall

class Model:
    def __init__(self, textInputSize: int | None = 256, maxSymbNum: int | None = 256, learning: bool = True):
        try:
            self.model = load_model("model.h5")
        except:
            self.model = Sequential([
                Dense(512, activation=relu, input_shape=(textInputSize,)),
                Dense(256, activation=relu),
                Dense(128, activation=relu),

                Dropout(0.5),

                Dense(2, activation=sigmoid)
            ])

            if learning:
                self.model.compile(optimizer=Adam(learning_rate=0.001), loss="categorical_crossentropy", metrics=[Accuracy(), Precision(), Recall()])

    def save(self):
        self.model.save("model.h5")

    def predict(self, text_indexes: list):
        return self.model.predict(text_indexes)[0]
    
    def fit(self, x_data: list, y_data: list, epochs: int = 100):
        self.model.fit(x_data, y_data, epochs=epochs, verbose=1, batch_size=64, steps_per_epoch=len(x_data)//64)