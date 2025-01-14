import os
import re
import json
import argparse
import base64
import email
from email import charset
from pathlib import Path
import pandas as pd
import requests
from requests.auth import HTTPBasicAuth
from concurrent.futures import ThreadPoolExecutor, as_completed, wait
from databricks import sql



def process_file(dbqueryfile:str):
  # This is the main function that invokes the regex templates to convert the dialect. the transpiler is distributed so each file is transformed independently before being written out.
   
  
  with open(dbqueryfile, 'r+') as file:
    content = file.read()

    with sql.connect(server_hostname = "xxx",
                 http_path       = "yyy",
                 access_token    = "zzz") as connection:

      with connection.cursor() as cursor:
        cursor.execute(content)
        rows = cursor.fetchall()
        querycount = rows.length()
        dqdict = {'path': dbqueryfile, 'count': querycount}
        utlist.append(dqdict)


def runner(dbquerydir:str):
  # This is the runner function that first finds files to parse and then invokes the main transpiler methods to convert the dialect. the transpiler is distributed so each file is transformed independently before being written out.

  ## The package version assumes the utility helper lives under /project_folder/packages/lakehouse_utils/helper/. So it looks 3 levels up for a dbt_project file and uses that as the base directory
 
  files = find_files(dbquerydir)
  files_array = []
  with ThreadPoolExecutor() as executor:
    futures_sql = {executor.submit(process_file, p): p for p in files}
  utilsdf = spark.createDataFrame(utlist)
  utilsdf.write.saveAsTable("prodrs.default.dbxutresults") 
  print('woohoo, weve reached the end of the road (but still i cant let go)') 



def find_files(dbquerydir:str):
    # Convert the input to a Path object
    path = Path(dbquerydir)

    # Check if the provided path is a directory
    if not path.is_dir():
        raise NotADirectoryError(f"{directory} is not a directory.")

    # List to store all .sql file paths
    files = []

    # Use glob to find all .sql files recursively
    for file in path.rglob('*.sql'):
       files.append(str(file))

    return files


if __name__ == '__main__':

    dbquerydir = '/Workspace/Users/roberto.salcido@databricks.com/simplecta/dbqueries/noparams'
    utlist = []

    ## Now do project conversion
