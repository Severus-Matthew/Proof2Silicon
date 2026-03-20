import os
import shutil
import subprocess

def run_dafny_files(directory):
    """
    Executes all .dfy files in the given directory using Dafny.exe.

    Args:
        directory (str): The path to the directory containing .dfy files.
    """
    # Ensure the provided directory exists
    if not os.path.exists(directory):
        print(f"Error: The directory {directory} does not exist.")
        return

    verified_folder = "D:\\UIUC_PROJ_2\\Data_verified"
    compiled_folder = "D:\\UIUC_PROJ_2\\Data_verified_compiled"
    error_folder= "D:\\UIUC_PROJ_2\\error"
    timeou_folder="D:\\UIUC_PROJ_2\\timeout"

    # Ensure the output folders exist
    os.makedirs(verified_folder, exist_ok=True)
    os.makedirs(compiled_folder, exist_ok=True)

    # Loop through all files in the directory
    for filename in os.listdir(directory):
        if filename.endswith(".dfy"):
            file_path = os.path.join(directory, filename)
            verify_path = os.path.join(verified_folder, filename)
            compiled_path = os.path.join(compiled_folder, filename)
            error_path= os.path.join(error_folder, filename)
            timeout_path= os.path.join(timeou_folder,filename)

            if not os.path.exists(verify_path) and not os.path.exists(compiled_path) and not os.path.exists(error_path) and not os.path.exists(timeout_path):
                try:
                    print(f"Running {filename}...")

                    # Change directory before running Dafny.exe
                    os.chdir("C:\\Users\\drpro\\Downloads\\dafny-4.5.0-x64-windows-2019\\dafny\\")

                    # Run the Dafny.exe command with a timeout of 300 seconds (5 minutes)
                    result = subprocess.run([
                        "./Dafny.exe", file_path
                    ], capture_output=True, text=True, timeout=300)

                    # Print the output and errors
                    print(f"Output for {filename}:")
                    print(result.stdout)

                    if result.stderr:
                        print(f"Errors for {filename}:")
                        print(result.stderr)

                    # Check if the file is verified with 0 errors
                    if "verified, 0 errors" in result.stdout:
                        # Check if it is also compiled
                        if "Compiled assembly into" in result.stdout:
                            # Save to compiled folder
                            shutil.copy(file_path, compiled_folder)
                        else:
                            # Save to verified folder
                            shutil.copy(file_path, verified_folder)
                    else:
                        shutil.copy(file_path, error_folder)

                except subprocess.TimeoutExpired:
                    print(f"Timeout: {filename} took more than 5 minutes to run. Skipping to the next file.")
                    shutil.copy(file_path, timeou_folder)
                except Exception as e:
                    print(f"Failed to run {filename}: {e}")

if __name__ == "__main__":
    # Replace 'your_directory_path_here' with the path to your directory
    directory_path = "D:\\UIUC_PROJ_2\\dataset\\hints_removed\\"
    run_dafny_files(directory_path)
