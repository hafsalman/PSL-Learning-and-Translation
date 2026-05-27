import json
from firebase_admin import credentials, initialize_app, firestore

cred = credentials.Certificate("serviceAccountKey.json")
initialize_app(cred)
db = firestore.client()

with open("psl_data.json", "r", encoding="utf-8") as f:
    data = json.load(f)

for chapter_name, words in data.items():
    print(f"Uploading chapter: {chapter_name}")

    chapter_ref = db.collection("chapters").document(chapter_name)
    chapter_ref.set({"name": chapter_name})

    for word_entry in words:
        word_name = word_entry["word"]
        print(f"  - {word_name}")

        word_ref = chapter_ref.collection("words").document(word_name)
        word_ref.set(word_entry)

with open("psl_data.json", "r", encoding="utf-8") as f:
    data = json.load(f)

print("\nDONE — Data uploaded to Firestore successfully!")