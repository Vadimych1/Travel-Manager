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

def summarize(text: str, lang: str = "russian", sentences_n: int = 3, max_words: int = 30) -> str:
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
                if len(sent.split(' ')) < max_words:
                    if sent not in sentence_scores.keys():
                        sentence_scores[sent] = word_frequencies[word]
                    else:
                        sentence_scores[sent] += word_frequencies[word]

    summary_sentences = heapq.nlargest(sentences_n, sentence_scores, key=sentence_scores.get)

    return ' '.join(summary_sentences)

if __name__ == "__main__":
    s = summarize("""
    Достопримеча́тельность — место, вещь или объект, заслуживающие особого внимания, знаменитые или замечательные чем-либо, например, являющиеся историческим наследием, художественной ценностью.
Примеры: места исторических событий, зоопарки, памятники, музеи и галереи, ботанические сады, здания и сооружения (например, замки, библиотеки, бывшие тюрьмы, небоскрёбы, мосты), национальные парки и заповедники, леса, парки развлечений, карнавалы и ярмарки, культурные события и т. п. Многие достопримечательности также являются ориентирами.
Достопримечательностями также могут быть места странных и необъяснимых явлений, например озеро Лох-Несс (благодаря Лох-Несскому чудовищу) в Шотландии или место предполагаемого крушения НЛО неподалёку от Розуэлла в США. Места предполагаемого появления привидений также являются достопримечательностями.
Места компактного проживания определённой этнической группы населения также могут стать достопримечательностями (например индейские резервации или китайские кварталы в некоторых городах).
Достопримечательность — это не просто памятник истории или искусства, но объект массового потребления, своеобразный конструкт, товар, созданный массовой культурой для удовлетворения запросов нового типа потребителя. Конструирование достопримечательностей включает ряд операций: переведение памятника из поля функционирования искусства в поле функционирования массовой культуры; упрощение, а порой и искажение смыслов, ценностей, значений; тиражирование и организация массового потребления; переведение из сферы незаинтересованного эстетического восприятия в сферу престижного потребления[1].
Достопримечательность «живёт» не в истории искусства, не в других узкопрофессиональных сферах, а в массовой культуре. Чем больше объект присваивается массовой культурой и уходит из сферы профессиональной, элитарной, тем более он известен, популярен, тем больше интереса он представляет для туриста[2].
""")

    print(s)  