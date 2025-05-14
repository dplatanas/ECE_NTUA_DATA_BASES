# Pulse Festival database implementation project
A simple implementation for the needs of a Music Festival made with MySQL MariaDB Version 11.4.5.

Team: DIONISIOS-EFRAIM PLATANAS, DHMHTRIOS BASILARAS, BASILEIOS KALIATSIS
## Prerequisite installation steps for Linux (Debian Core) for Faker library:
#### Get the latest version of Python and create a Virtual enviroment for installation of faker libary
``` bash
sudo apt-get update
sudo apt-get install python3.8
```
#### Create a new virtual environment, pick a folder name (commonly venv or .venv)
``` bash
sudo apt install python3-venv
python3 -m venv venv
```
#### Activate the virtual environment
``` bash
source venv/bin/activate
```
#### Upgrade pip and install the Faker library
``` bash
pip install faker
```
#### When you’re done… deactivate
``` bash
deactivate
```
#### After this copy the file from the folder code/generate_data.py to your linux terminal and run the following command:
``` bash
python3 generate_data.py
```
#### The new file load.sql contains the dummy_data for the database to be inserted.
