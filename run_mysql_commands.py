import subprocess

# Define the commands to run
commands = [
    'mysql --user=root --password=root cbioportal < C:\\Users\\Shubham\\Desktop\\Database\\cgds.sql',
    'mysql --user=root --password=root cbioportal < C:\\Users\\Shubham\\Desktop\\Database\\cgds.sql'
]

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

# Execute each command
for cmd in commands:
    run_command(cmd)
