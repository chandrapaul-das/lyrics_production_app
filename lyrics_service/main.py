from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import google.generativeai as genai
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

gemini_api_key = 'AIzaSyAMuWjUrdIB69nuEwmnvecT0HfUWejfCGk'
genai.configure(api_key=gemini_api_key)

class SongRequest(BaseModel):
    lang: str
    genre: str
    desc: str

@app.post("/generate-lyrics/")
async def generate_lyrics(request: SongRequest):
    try:
        if request.desc == "":
            desc_part = ""
        else:
            desc_part = f'''
                Here's a short description of the song: {request.desc}.'''

        lyrics = {"lyrics_1": "", "lyrics_2": ""}
        types = ['The song should be have hard-hitting serious words.', 'The song should be made with casual words.']
        for i in range(len(types)):
            model = genai.GenerativeModel('gemini-1.5-flash')
            response = model.generate_content(
                f'''Generate a song lyrics in {request.lang} language and {request.genre} genre. {types[0]}{desc_part}
                ###Important: Only give the lyrics as output.''',
                generation_config=genai.types.GenerationConfig(
                    candidate_count=1,
                    temperature=1
                )
            )
            lyrics[f"lyrics_{i+1}"] = response.text

        return lyrics

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))