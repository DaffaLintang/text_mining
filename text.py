import time
import logging
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from urllib.parse import urlparse, urlunparse
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
from deep_translator import GoogleTranslator
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Setup Selenium
chrome_driver_path = r"C:\ChormeWebDriver\chromedriver-win64\chromedriver.exe"
chrome_options = Options()
chrome_options.add_argument("--disable-blink-features=AutomationControlled")
chrome_options.add_argument("--incognito")

service = Service(chrome_driver_path)
driver = webdriver.Chrome(service=service, options=chrome_options)

# Mengakses halaman review
original_url = "https://www.tokopedia.com/tokoexpert/asus-dual-rx-6600-8gb-gddr6"
parsed_url = urlparse(original_url)
review_url = urlunparse((parsed_url.scheme, parsed_url.netloc, parsed_url.path + "/review", "", "", ""))

logging.info(f"Mengakses halaman: {review_url}")
driver.get(review_url)
WebDriverWait(driver, 20).until(lambda d: d.title.strip() != "")
time.sleep(5)

# Scraping review
all_reviews = []
current_page = 1
while True:
    try:
        review_feed = driver.find_element(By.ID, "review-feed")
        reviews = review_feed.find_elements(By.XPATH, ".//span[@data-testid='lblItemUlasan']")
        
        for review in reviews:
            review_text = review.text.strip()
            if review_text and review_text not in all_reviews:
                all_reviews.append(review_text)
        
        logging.info(f"Halaman {current_page} - {len(reviews)} review ditemukan.")

        try:
            next_button = WebDriverWait(driver, 5).until(
                EC.presence_of_element_located((By.XPATH, "//button[contains(@aria-label, 'Laman berikutnya')]")
            )
        )

            if next_button.get_attribute("disabled") is not None:
                logging.info("Tidak ada halaman berikutnya. Scraping selesai.")
                break

            driver.execute_script("arguments[0].click();", next_button)
            time.sleep(3)
            current_page += 1

        except Exception:
            logging.info("Tidak ada halaman berikutnya. Scraping selesai.")
            break

    except Exception as e:
        logging.error(f"Error saat mengambil review: {e}")
        break

driver.quit()

# Analisis Sentimen VADER
def analyze_sentiment_vader(text):
    if not text:  # Cek jika teks kosong atau None
        logging.warning("Teks kosong atau None, tidak dapat menganalisis sentimen.")
        return "Netral"

    translated_text = GoogleTranslator(source='id', target='en').translate(text)
    if translated_text is None:  # Pastikan translated_text bukan None
        translated_text = ""

    analyzer = SentimentIntensityAnalyzer()
    scores = analyzer.polarity_scores(translated_text)

    if scores['compound'] >= 0.05:
        return "Positif"
    elif scores['compound'] <= -0.05:
        return "Negatif"
    else:
        return "Netral"

# Menampilkan hasil sentimen
pos_count = 0
neg_count = 0
net_count = 0

logging.info("Hasil Sentiment Analysis (VADER):")
for i, review in enumerate(all_reviews, start=1):
    sentiment = analyze_sentiment_vader(review)
    if sentiment == "Positif":
        pos_count += 1
    elif sentiment == "Negatif":
        neg_count += 1
    else:
        net_count += 1
    print(f"{i}. Sentimen: {sentiment} | Review: {review}")

print("\nRingkasan Sentimen:")
print(f"Positif: {pos_count}")
print(f"Negatif: {neg_count}")
print(f"Netral: {net_count}")
