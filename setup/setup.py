import pandas as pd
import psycopg2
from psycopg2 import sql
import time

# Function to load .tsv.gz file into psql
def load_file_into_table(file_path, table_name, conn):

    count = 0

    # Read the .tsv.gz file into pandas
    for chunk in pd.read_csv(file_path, delimiter='\t', compression='gzip', chunksize=10000):

        # Set \N to NULL
        chunk.replace("\\N", None, inplace=True)

        # Drop all titles except theatrically released movies
        if table_name == "title_basics":
            chunk = chunk[chunk.titleType == "movie"]
            tconsts_in_title_basics.update(chunk.tconst.values)
        elif table_name == "title_principals":
            chunk = chunk[chunk.tconst.isin(tconsts_in_title_basics)]
            nconsts_in_title_principals.update(chunk.nconst.values)
        elif table_name == "name_basics":
            chunk = chunk[chunk.nconst.isin(nconsts_in_title_principals)]
        elif table_name == "title_ratings":
            chunk = chunk[chunk.tconst.isin(tconsts_in_title_basics)]
        
        # If chunk is empty after filtering, skip the rest of the loop
        if chunk.empty:
            continue

        # Establish connection to psql database
        cur = conn.cursor()

        # Iterate over rows of df and insert each into psql
        for _, row in chunk.iterrows():
            insert = sql.SQL("INSERT INTO {0} VALUES ({1})").format(
                sql.Identifier(table_name), 
                sql.SQL(',').join(sql.Placeholder() * len(row))
            )
            cur.execute(insert, tuple(row))
            count += 1
            if count % 1000 == 0:
                print(f'{count} records inserted into {table_name} so far...')

    # Commit changes and close cursor
    conn.commit()
    cur.close()
    print(f'Inserted {count} records into {table_name}!')

time.sleep(5)

conn = psycopg2.connect(
    dbname = "imdb",
    user = "postgres",
    password = "postgres",
    host = "db",
    port = 5432
    )

tables = {
    "./data/title.basics.tsv.gz": "title_basics",
    "./data/title.principals.tsv.gz": "title_principals",
    "./data/name.basics.tsv.gz": "name_basics",
    "./data/title.ratings.tsv.gz": "title_ratings"
    }

# Store tconst values from title_basics and nconst values from title_principals
tconsts_in_title_basics = set()
nconsts_in_title_principals = set()

for path, table in tables.items():
    load_file_into_table(path, table, conn)

cur = conn.cursor()

# Execute the function
cur.execute("SELECT calculate_bacon_number();")

# Close communication with the database
cur.close()
conn.close()