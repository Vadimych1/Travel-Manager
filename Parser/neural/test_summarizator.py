import re
import nltk, heapq

nltk.download('stopwords')
nltk.download('punkt')

def remove_special_characters(text):
    pattern = r'[^A-Za-z0-9\s]'
    text = re.sub(pattern, '', text)
    return text

def prepair_sentences(text: str) -> list:
    sentences = nltk.sent_tokenize(text)
    return sentences

def summarize(text: str, lang: str = "russian") -> str:
    sentences = prepair_sentences(text)
    stopwords = nltk.corpus.stopwords.words(lang)

    word_frequencies = {}
    for word in nltk.word_tokenize(text):
        if word not in stopwords:
            if word not in word_frequencies.keys():
                word_frequencies[word] = 1
            else:
                word_frequencies[word] += 1

    maximum_frequncy = max(word_frequencies.values())

    for word in word_frequencies.keys():
        word_frequencies[word] = (word_frequencies[word]/maximum_frequncy)
        sentence_scores = {}

    for sent in sentences:
        for word in nltk.word_tokenize(sent.lower()):
            if word in word_frequencies.keys():
                if len(sent.split(' ')) < 30:
                    if sent not in sentence_scores.keys():
                        sentence_scores[sent] = word_frequencies[word]
                    else:
                        sentence_scores[sent] += word_frequencies[word]

    summary_sentences = heapq.nlargest(7, sentence_scores, key=sentence_scores.get)

    return ' '.join(summary_sentences)

if __name__ == "__main__":
    s = summarize("""
    Однажды летом мы с родителями решили поехать на пикник в лес, который есть за городом. Мама приготовила еду для пикника. Она приготовила для похода пирожки, сварила вкусный компот, в магазине мы купили мороженое, мясо и фрукты. Папа купил уголь, чтобы сделать шашлык.
    Рано утром мы поехали на машине в лес. Там у нас есть любимая поляна для пикника. Мы приехали. Папа расчистил место для костра. Для этого он взял лопату и убрал верхний слой почвы с травой. Потом папа развел костер и стал готовить шашлык. Мы с мамой расстелили покрывало и стали раскладывать пирожки, фрукты, налили компот. Потом мы стали играть в настольные игры, фотографироваться на фоне красивой природы. Когда шашлык был готов, мы сели обедать. На десерт мама достала из переносного холодильника мороженое. После обеда мы еще немного поиграли, а потом стали собираться домой. Мы убрали за собой весь мусор, папа закопал потухший костер и вернул на место землю с травой.
    По дороге домой на мусорке мы выбросили весь мусор, который остался после пикника.
    Вот так мы отдохнули на лесной поляне.
""")

    print(s)  