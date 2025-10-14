import time
import logging
import nltk
nltk.download('punkt')
nltk.download('punkt_tab')
import re
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from urllib.parse import urlparse, urlunparse
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import pandas as pd

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

chrome_options = Options()
chrome_options.add_argument("--start-maximized")

service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service, options=chrome_options)

# Setup Selenium
chrome_driver_path = r"C:\\ChormeWebDriver\\chromedriver-win64\\chromedriver.exe"

# Mengakses halaman review
original_url = "https://www.tokopedia.com/liger-official-store/liger-handsfree-headset-earphone-l-10-metal-stereo-bass-biru-1731543200578176211?source=homepage.top_carousel.0.39123"
parsed_url = urlparse(original_url)
review_url = urlunparse((parsed_url.scheme, parsed_url.netloc, parsed_url.path + "/review", "", "", ""))

driver.get(review_url)
WebDriverWait(driver, 20).until(lambda d: d.title.strip() != "")
time.sleep(5)

# Scraping review
all_reviews = []
while True:
    try:
        review_feed = driver.find_element(By.ID, "review-feed")
        reviews = review_feed.find_elements(By.XPATH, ".//span[@data-testid='lblItemUlasan']")
        
        for review in reviews:
            review_text = review.text.strip()
            if review_text and review_text not in all_reviews:
                all_reviews.append(review_text)
        
        try:
            next_button = WebDriverWait(driver, 5).until(
                EC.presence_of_element_located((By.XPATH, "//button[contains(@aria-label, 'Laman berikutnya')]")
            )
        )
            if next_button.get_attribute("disabled") is not None:
                break
            driver.execute_script("arguments[0].click();", next_button)
            time.sleep(3)
        except Exception:
            break

    except Exception as e:
        logging.error(f"Error saat mengambil review: {e}")
        break

driver.quit()

# Preprocessing
stemmer = StemmerFactory().create_stemmer()
try:
    nltk.data.find('corpora/stopwords')
except LookupError:
    nltk.download('stopwords')
try:
    nltk.data.find('tokenizers/punkt')
except LookupError:
    nltk.download('punkt')
stop_words = set(stopwords.words('indonesian'))

def preprocess_text(text):
    text = text.lower()
    text = re.sub(r'[^a-zA-Z\s]', '', text)
    words = word_tokenize(text)
    words = [stemmer.stem(word) for word in words if word not in stop_words]
    return ' '.join(words)

# Load Dataset untuk Training
# Contoh dataset dummy (Bisa diganti dengan dataset nyata)
dataset = {
    "text": [
        "produk ini sangat bagus, saya suka sekali!",
        "barang jelek, tidak sesuai deskripsi!",
        "pengiriman cepat, barang sesuai harapan",
        "saya kecewa dengan kualitasnya",
        "harga murah dan kualitas bagus",
        "tidak direkomendasikan, sangat buruk"
    ],
    "label": ["Positif", "Negatif", "Positif", "Negatif", "Positif", "Negatif"]
}

df = pd.DataFrame(dataset)
df['text'] = df['text'].apply(preprocess_text)

# Splitting data untuk training dan testing
X_train, X_test, y_train, y_test = train_test_split(df['text'], df['label'], test_size=0.2, random_state=42)

# Membuat model Naïve Bayes dengan TF-IDF
model = make_pipeline(TfidfVectorizer(), MultinomialNB())
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
logging.info(f"Akurasi Model: {accuracy_score(y_test, y_pred) * 100:.2f}%")

# Prediksi Sentimen Review yang di-Scrape
logging.info("Hasil Sentimen Analysis (Naïve Bayes):")
for i, review in enumerate(all_reviews, start=1):
    preprocessed_review = preprocess_text(review)
    sentiment = model.predict([preprocessed_review])[0]
    print(f"{i}. Sentimen: {sentiment} | Review: {review}")