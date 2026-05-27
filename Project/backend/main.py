from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate("serviceAccountKey.json")
initialize_app(cred)
db = firestore.client()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.get("/chapters")
def get_chapters():
    """Return list of all chapters"""
    docs = db.collection("chapters").stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]


@app.get("/chapters/{chapter_id}/words")
def get_words(chapter_id: str):
    """Return list of words in the chapter"""
    docs = db.collection("chapters").document(chapter_id).collection("words").stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]


@app.get("/chapters/{chapter_id}/words/{word_id}")
def get_video(chapter_id: str, word_id: str):
    """Return video info for selected word"""
    doc = db.collection("chapters").document(chapter_id)\
        .collection("words").document(word_id).get()

    if not doc.exists:
        return {"error": "Word not found"}

    return doc.to_dict()
