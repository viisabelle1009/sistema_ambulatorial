import pymysql

def conectar():
    conexao = pymysql.connect(
        host="localhost",
        user="root",
        password="1234",
        database="hospital_ambulatorial"
    )
    return conexao

