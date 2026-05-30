import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port="2891",
    database="postgres",
    user="postgres",
    password="pal12345@"
)

print("Connected Successfully!")