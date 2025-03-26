import psycopg2
import csv
from datetime import datetime
import os

#NOTA: Cambiar los valores de las variables de conexión según corresponda a su configuración de base de datos. 
DB_NAME = "tgcpokemon_db"
DB_USER = "postgres"
DB_PASSWORD = "12345678" 
DB_HOST = "localhost"  
DB_PORT = "5432"    

CSV_FILES = [
    "modern_pkmn_cards_feb2025.csv",
    "modern_pkmn_cards_mar2025.csv",
    "vintage_pkmn_cards_feb2025.csv",
    "vintage_pkmn_cards_mar2025.csv"
]

def connect_to_db():
    """Establish connection to PostgreSQL database"""
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def insert_card_data(conn, card_data):
    """Insert card data into cartas table"""
    query = """
    INSERT INTO cartas (
        id, name, pokedex_number, supertype, subtypes, hp, types, attacks,
        weaknesses, retreat_cost, set_name, release_date, artist, rarity,
        card_image_small, card_image_hires, tcg_player_url
    ) VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
    ) ON CONFLICT (id) DO NOTHING
    """
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(query, card_data)
        conn.commit()
        return True
    except Exception as e:
        conn.rollback()
        print(f"Error inserting card data: {e}")
        return False

def insert_price_data(conn, price_data):
    """Insert price data into precios table"""
    query = """
    INSERT INTO precios (
        carta_id, precio, tipo_precio, fecha
    ) VALUES (
        %s, %s, %s, %s
    )
    """
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(query, price_data)
        conn.commit()
        return True
    except Exception as e:
        conn.rollback()
        print(f"Error inserting price data: {e}")
        return False

def process_csv_file(conn, file_path):
    """Process a single CSV file and insert data into database"""
    try:
        filename = os.path.basename(file_path)
        date_part = filename.split('_')[-1].split('.')[0] 
        month = date_part[:3].lower()
        year = date_part[3:]
        
        month_num = {
            'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
            'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
        }.get(month, 1)
        
        price_date = datetime(int(year), month_num, 1).date()
        
        with open(file_path, 'r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            
            for row in reader:
                card_data = (
                    row['ID'],
                    row['Name'],
                    int(float(row['Pokedex Number'])) if row['Pokedex Number'] else None,
                    row['Supertype'],
                    row['Subtypes'],
                    int(row['HP']) if row['HP'] and row['HP'].isdigit() else None,
                    row['Types'],
                    row['Attacks'],
                    row['Weaknesses'],
                    row['Retreat Cost'],
                    row['Set Name'],
                    datetime.strptime(row['Release Date'], '%Y/%m/%d').date() if row['Release Date'] else None,
                    row['Artist'],
                    row['Rarity'],
                    row['Card Image (Small)'],
                    row.get('Card Image HiRes', None),  
                    row.get('TCG Player URL', None) 
                )
                
                insert_card_data(conn, card_data)
                
                price_types = {
                    'Normal': row.get('TCG Market Price USD (Normal)'),
                    'Reverse Holofoil': row.get('TCG Market Price USD (Reverse Holofoil)'),
                    'Holofoil': row.get('TCG Market Price USD (Holofoil)')
                }
                
                for tipo_precio, price in price_types.items():
                    if price and price.strip() and price != 'N/A':
                        try:
                            price_value = float(price)
                            price_data = (
                                row['ID'],
                                price_value,
                                tipo_precio,
                                price_date
                            )
                            insert_price_data(conn, price_data)
                        except ValueError:
                            print(f"Invalid price value for {row['ID']} - {tipo_precio}: {price}")
                            continue
    
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")

def main():
    conn = connect_to_db()
    if not conn:
        return
    
    try:
        for csv_file in CSV_FILES:
            if os.path.exists(csv_file):
                print(f"Processing file: {csv_file}")
                process_csv_file(conn, csv_file)
            else:
                print(f"File not found: {csv_file}")
        
        print("Data import completed successfully!")
    finally:
        conn.close()

if __name__ == "__main__":
    main()