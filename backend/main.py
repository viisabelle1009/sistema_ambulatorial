from fastapi import FastAPI
from backend.database import conectar

app = FastAPI()

@app.get("/")
def home():
    conexao = conectar()
    cursor = conexao.cursor()

    cursor.execute("SELECT 1")

    return {"mensagem": "API conectada ao MySQL"}




    