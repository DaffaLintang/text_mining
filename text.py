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
import joblib
from scipy.sparse import hstack, csr_matrix
import numpy as np
from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import uuid
import threading
import json
import traceback

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def get_reviews_and_category(shortlink: str):
    chrome_options = Options()
    chrome_options.add_argument("--start-maximized")
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-blink-features=AutomationControlled")
    chrome_options.add_argument("--window-size=1366,768")
    chrome_options.add_argument(
        "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0 Safari/537.36"
    )
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=chrome_options)
    try:
        driver.get(shortlink)
        # Wait for redirect off the shortlink and into tokopedia domain
        WebDriverWait(driver, 40).until(lambda d: d.current_url != shortlink)
        WebDriverWait(driver, 40).until(lambda d: "tokopedia.com" in d.current_url)
        time.sleep(2)
        original_url = driver.current_url
        if not original_url or original_url == shortlink:
            raise RuntimeError(f"Redirect did not resolve. current_url='{driver.current_url}'")
        parsed_url = urlparse(original_url)
        review_path = parsed_url.path.rstrip('/') + "/review"
        review_url = urlunparse((parsed_url.scheme, parsed_url.netloc, review_path, "", "", ""))

        driver.get(review_url)
        if not WebDriverWait(driver, 40).until(lambda d: d.title.strip() != ""):
            raise RuntimeError("Halaman review tidak memuat title")
        time.sleep(5)

        all_reviews = []
        category = ""
        while True:
            try:
                try:
                    review_feed = WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.ID, "review-feed")))
                except Exception:
                    raise RuntimeError("Elemen review-feed tidak ditemukan")
                reviews = review_feed.find_elements(By.XPATH, ".//span[@data-testid='lblItemUlasan']")
                category = WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.XPATH, "//nav[@aria-label='Breadcrumb']//ol/li[2]//a"))
                ).text.strip()

                for review in reviews:
                    try:
                        parent_container = review.find_element(By.XPATH, "./ancestor::*[self::div or self::li][1]")
                        more_button = parent_container.find_element(By.XPATH, ".//button[contains(normalize-space(.), 'Selengkapnya')]")
                        driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", more_button)
                        driver.execute_script("arguments[0].click();", more_button)
                        try:
                            WebDriverWait(driver, 5).until(EC.staleness_of(more_button))
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
                logging.error(f"Error saat mengambil review: {type(e).__name__}: {e!r}")
                break
        return all_reviews, category
    finally:
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

model = joblib.load('naive_bayes_model.pkl')
vectorizer = joblib.load('tfidf_vectorizer.pkl')

app = Flask(__name__)
# Allow CORS for local file:// (Origin: null) and any origin during development
CORS(app, resources={r"/analyze": {"origins": "*"}, r"/stream/*": {"origins": "*"}})

# In-memory job progress store
PROGRESS = {}
PROGRESS_LOCK = threading.Lock()

def set_progress(job_id, status=None, percent=None, message=None, data=None):
    with PROGRESS_LOCK:
        st = PROGRESS.get(job_id, {"status": "pending", "percent": 0, "message": "", "data": None})
        if status is not None:
            st["status"] = status
        if percent is not None:
            st["percent"] = percent
        if message is not None:
            st["message"] = message
        if data is not None:
            st["data"] = data
        PROGRESS[job_id] = st

def _run_analysis_job(job_id, shortlink):
    try:
        set_progress(job_id, status="running", percent=5, message="Resolving shortlink...")
        reviews, category_name = get_reviews_and_category(shortlink)
        set_progress(job_id, percent=30, message=f"Scraped {len(reviews)} reviews; preprocessing...")

        texts_preprocessed = [preprocess_text(r) for r in reviews]
        if not texts_preprocessed:
            set_progress(job_id, status="completed", percent=100, message="No reviews found", data={"category": category_name, "items": []})
            return

        set_progress(job_id, percent=55, message="Vectorizing...")
        X_text = vectorizer.transform(texts_preprocessed)
        encoded_category = category_map.get(category_name, 20)
        X_cat = csr_matrix(np.full((len(reviews), 1), encoded_category))

        set_progress(job_id, percent=75, message="Predicting sentiments...")
        X_final = hstack([X_text, X_cat])
        preds = model.predict(X_final)

        items = []
        for i, (review, p) in enumerate(zip(reviews, preds), start=1):
            label = "Positif" if p == 1 else ("Negatif" if p == 0 else str(p))
            items.append({"sentiment": label, "review": review})
            # Optional fine-grained progress
            set_progress(job_id, percent=75 + int(20 * (i/len(reviews))), message=f"Aggregating results {i}/{len(reviews)}...")

        result = {
            "category": category_name,
            "category_encoded": encoded_category,
            "count": len(items),
            "items": items
        }
        set_progress(job_id, status="completed", percent=100, message="Done", data=result)
    except Exception as e:
        tb = traceback.format_exc()
        set_progress(job_id, status="failed", percent=100, message=str(e) or "Unhandled error", data={"error": str(e), "traceback": tb})

@app.post('/analyze')
def analyze():
    data = request.get_json(silent=True) or {}
    shortlink = data.get('shortlink')
    if not shortlink:
        return jsonify({"error": "shortlink is required"}), 400

    job_id = uuid.uuid4().hex
    set_progress(job_id, status="queued", percent=0, message="Job queued")
    t = threading.Thread(target=_run_analysis_job, args=(job_id, shortlink), daemon=True)
    t.start()
    return jsonify({"job_id": job_id}), 202

@app.get('/stream/<job_id>')
def stream(job_id):
    def gen():
        last_payload = None
        while True:
            with PROGRESS_LOCK:
                st = PROGRESS.get(job_id)
            if not st:
                yield f"data: {json.dumps({'error': 'unknown job_id'})}\n\n"
                break
            payload = {"status": st.get("status"), "percent": st.get("percent"), "message": st.get("message")}
            if payload != last_payload:
                yield f"data: {json.dumps(payload)}\n\n"
                last_payload = payload
            if st.get("status") in ("completed", "failed"):
                # send final data when completed
                if st.get("data") is not None:
                    yield f"data: {json.dumps({'status': st['status'], 'percent': st['percent'], 'message': st['message'], 'result': st['data']})}\n\n"
                break
            time.sleep(1)
    return Response(
        gen(),
        mimetype='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Access-Control-Allow-Origin': '*'
        }
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)