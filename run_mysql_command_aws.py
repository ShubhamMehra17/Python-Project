import subprocess
import boto3
import os

# AWS S3 and RDS configurations
s3_bucket = 'codetestsqlbucket'
s3_key_cgds = 'sqlscript/cgds.sql'
s3_key_seed = 'sqlscript/seed_database.sql'
local_cgds_file = 'C:/Users/Shubham/Desktop/AWS_Database/cgds.sql'
local_seed_file = 'C:/Users/Shubham/Desktop/AWS_Database/seed_database.sql'

# RDS configuration
rds_host = 'database-1-instance-1.cp6osy44yfu0.us-east-1.rds.amazonaws.com'
rds_user = 'admin'
rds_password = 'root1234'
rds_database = 'cbioportal'

# Function to download file from S3
def download_from_s3(bucket, key, local_filename):
    s3 = boto3.client('s3')
    s3.download_file(bucket, key, local_filename)

# Function to run a command
def run_command(command):
    try:
        # Run the command
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print("Command Output:\n", result.stdout)
        if result.stderr:
            print("Command Error:\n", result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Command failed with error: {e}")

# Download SQL files from S3
download_from_s3(s3_bucket, s3_key_cgds, local_cgds_file)
download_from_s3(s3_bucket, s3_key_seed, local_seed_file)

# Define the commands to run
commands = [
    f'mysql --host={rds_host} --user={rds_user} --password={rds_password} {rds_database} < {local_cgds_file}',
    f'mysql --host={rds_host} --user={rds_user} --password={rds_password} {rds_database} < {local_seed_file}'
]

# Execute each command
for cmd in commands:
    run_command(cmd)

# Optionally, clean up local files
# os.remove(local_cgds_file)
# os.remove(local_seed_file)
