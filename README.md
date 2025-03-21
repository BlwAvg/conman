# ConMan

A horrible, web-based SSH connection manager (ConMan) built with Python and Flask. ConMan enables you to:
- View active SSH connections.
- Manage system users and SSH keys.
- Configure basic application settings.

## Requirements
- Python 3.6+ (tested on Python 3.x)
- Flask (`pip install flask` or `apt install python3-flask`)
- sudo privileges for the user running ConMan (needed for user creation, SSH key management).
- ss or netstat to list active SSH connections.

## Run the application
run the start.sh script in the scripts directory.
- My have to run as root? I will figure out permissions needed at some point.
- Do not forget to add execute permissions to scripts `chmod +x scripts/*`

## Folder Structure
```
conman/
├── conman.py               Main application
├── logs/
│   └── conman.log          Logs from the default webserver
├── static/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   ├── common.js
│   │   ├── dashboard.js
│   │   ├── manage.js
│   │   └── settings.js
├── templates/              Base HTML pages
│   ├── base.html
│   ├── dashboard.html
│   ├── manage.html
│   └── settings.html
├── scripts/                Used for storing scripts for making life easier. 
|   ├── start.sh
|   ├── stop.sh
|   └── Other helpful scripts stored here
```


# Troubleshooting
The app doesnt work right now. Need to add debugging code to figure out what the hell is going on. I also need to learn how to code.