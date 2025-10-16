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
import pandas as pd
import joblib
from scipy.sparse import hstack, csr_matrix
import numpy as np

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

chrome_options = Options()
chrome_options.add_argument("--start-maximized")

service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service, options=chrome_options)

# Setup Selenium
chrome_driver_path = r"C:\\ChormeWebDriver\\chromedriver-win64\\chromedriver.exe"

# Mengakses shortlink terlebih dahulu, ambil URL penuh, lalu buka halaman review
shortlink = "https://tk.tokopedia.com/ZSUuKmyJY"
driver.get(shortlink)
WebDriverWait(driver, 20).until(lambda d: d.current_url != shortlink)
time.sleep(2)
original_url = driver.current_url
parsed_url = urlparse(original_url)
review_path = parsed_url.path.rstrip('/') + "/review"
review_url = urlunparse((parsed_url.scheme, parsed_url.netloc, review_path, "", "", ""))

driver.get(review_url)
WebDriverWait(driver, 20).until(lambda d: d.title.strip() != "")
time.sleep(5)

# Scraping review
all_reviews = []
category = ""
while True:
    try:
        review_feed = driver.find_element(By.ID, "review-feed")
        reviews = review_feed.find_elements(By.XPATH, ".//span[@data-testid='lblItemUlasan']")
        category = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//nav[@aria-label='Breadcrumb']//ol/li[2]//a"))).text.strip()
        
        for review in reviews:
            try:
                parent_container = review.find_element(By.XPATH, "./ancestor::*[self::div or self::li][1]")
                more_button = parent_container.find_element(By.XPATH, ".//button[normalize-space()='Selengkapnya']")
                driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", more_button)
                driver.execute_script("arguments[0].click();", more_button)
                try:
                    WebDriverWait(driver, 5).until(EC.invisibility_of_element(more_button))
                except Exception:
                    time.sleep(0.5)
            except Exception:
                pass

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

# Mapping kategori breadcrumb (ID) ke encoding yang Anda sediakan (EN)
category_map = {
    "Perawatan Hewan": 0,                 # Animal Care
    "Otomotif": 1,                        # Automotive
    "Kecantikan": 2,                      # Beauty
    "Perawatan Tubuh": 3,                 # Body Care
    "Buku": 4,                            # Books
    "Audio, Kamera & Elektronik Lainnya": 5,  # Camera (atau gunakan 20 jika ingin 'Other Products')
    "Pertukangan": 6,                     # Carpentry
    "Komputer & Laptop": 7,               # Computers and Laptops
    "Elektronik": 8,                      # Electronics
    "Makanan & Minuman": 9,               # Food and Drink
    "Gaming": 10,                         # Gaming
    "Kesehatan": 11,                      # Health
    "Rumah Tangga": 12,                   # Household
    "Fashion Anak & Bayi": 13,            # Kids and Baby Fashion
    "Dapur": 14,                          # Kitchen
    "Fashion Pria": 15,                   # Men's Fashion
    "Ibu & Bayi": 16,                     # Mother and Baby
    "Film & Musik": 17,                   # Movies and Music
    "Fashion Muslim": 18,                 # Muslim Fashion
    "Office & Stationery": 19,            # Office & Stationery
    "Lainnya": 20,                        # Other Products (fallback label jika ada)
    "Perlengkapan Pesta": 21,             # Party Supplies and Craft
    "Handphone & Tablet": 22,             # Phones and Tablets
    "Logam Mulia": 23,                    # Precious Metal
    "Properti": 24,                       # Property
    "Olahraga": 25,                       # Sport
    "Tiket, Travel, Voucher": 26,         # Tour and Travel
    "Mainan & Hobi": 27,                  # Toys and Hobbies
    "Fashion Wanita": 28,                 # Women's Fashion
}

encoded_category = category_map.get(category, 20)  # default ke Other Products bila tidak cocok

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

# Load kembali model dan komponen praproses
model = joblib.load('naive_bayes_model.pkl')
vectorizer = joblib.load('tfidf_vectorizer.pkl')

# Prediksi Sentimen Review yang di-Scrape
logging.info("Hasil Sentimen Analysis (Naïve Bayes):")
texts_preprocessed = [preprocess_text(r) for r in all_reviews]
if texts_preprocessed:
    X_text = vectorizer.transform(texts_preprocessed)
    # Gunakan encoding kategori numerik sesuai mapping yang diberikan
    X_cat = csr_matrix(np.full((len(all_reviews), 1), encoded_category))
    X_final = hstack([X_text, X_cat])
    preds = model.predict(X_final)
    for review, p in zip(all_reviews, preds):
        label = "Positif" if p == 1 else ("Negatif" if p == 0 else str(p))
        print(f"Sentimen: {label} | Review: {review}")