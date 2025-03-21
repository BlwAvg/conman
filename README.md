# ConMan

A simple, web-based SSH connection manager (ConMan) built with Python and Flask. ConMan enables you to:
- View active SSH connections.
- Manage system users and SSH keys.
- Configure basic application settings.

## Folder Structure
```
conman/
├── conman.py              (Main Flask web application)
├── logs/
│   └── conman.log
├── static/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   ├── common.js
│   │   ├── dashboard.js
│   │   ├── manage.js
│   │   └── settings.js
├── templates/
│   ├── base.html
│   ├── dashboard.html
│   ├── manage.html
│   └── settings.html
├── scripts/
|   ├── start.sh
|   └── stop.sh
```

## Requirements
- Python 3.6+ (tested on Python 3.x)
- Flask (`pip install flask` or `apt install python3-flask`)
- sudo privileges for the user running ConMan (needed for user creation, SSH key management).
- ss or netstat to list active SSH connections.
