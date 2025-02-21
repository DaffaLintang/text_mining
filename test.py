import nltk
nltk.download('punkt')  # Pastikan ini diunduh
nltk.download('stopwords')

from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
from sklearn.feature_extraction.text import TfidfVectorizer

# Preprocessing Function
def preprocess_text(text):
    # Tokenisasi
    tokens = word_tokenize(text.lower())  # Gunakan nltk.download('punkt')

    # Menghapus tanda baca dan stopwords
    stop_words = set(stopwords.words('indonesian'))  # Gunakan nltk.download('stopwords')
    tokens = [word for word in tokens if word.isalnum() and word not in stop_words]

    # Stemming
    factory = StemmerFactory()
    stemmer = factory.create_stemmer()
    tokens = [stemmer.stem(word) for word in tokens]

    return ' '.join(tokens)

# Contoh penggunaan
sample_text = "Ini adalah contoh review produk yang sangat bagus!"
processed_text = preprocess_text(sample_text)
print(processed_text)
