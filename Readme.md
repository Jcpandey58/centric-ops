Centric Ops Automation Script

# Overview
This repository provides a configurable automation script designed to simplify and automate recurring operational activities typically handled by functional teams.

The script helps in reducing manual efforts for:
1. Database backups and restores
2. URL exposure
3. Starting, stopping, and restarting key services:
    WildFly Service
    PDF Service
    Image Service

# Features: 

1. Database Backup
   Automates backup of the configured database.

2. Database Restore (Under Implementation)
   Functionality to restore databases from backups is in progress.

3. URL Exposure
   Automates URL exposure along with required configuration updates and WildFly service restart.

4. Service Operations
   Provides controls to:
   Start, Stop, Restart the following services:
   WildFly
   PDF Service
   Image Service


# Configuration: 
Operational actions are driven by the config.properties file:

Database
db.server=localhost
db.backup=false
db.restore=false  # Under Implementation

URL Exposure
url.expose=false

Service Controls
restart.WildFly.service=false
restart.PDF.service=false      
restart.Image.service=false

stop.WildFly.service=true
stop.PDF.service=false
stop.Image.service=true

start.service=false
start.PDF.service=true
start.Image.service=true

Set the respective options to true or false to enable or disable each operation.


# Logs
All execution activities, statuses, and errors are logged for better traceability and debugging.
Logs are stored in the logs folder within the project directory.

A log rotation mechanism is implemented:
Maximum of 4 log files retained
Each file is capped at 100 KB
Total log storage is limited to 400 KB
Older logs are automatically rotated to maintain space efficiency.

This ensures that logging is detailed without consuming excessive disk space.

# Usage
Download the [Zipfile](https://github.com/Jcpandey58/centric-ops/archive/refs/heads/main.zip)
Configure the tasks in the Propertes file
Run the Runner.ps1 to execute the configured tasks.


# Contribution
Contributions and suggestions for improvements are welcome.