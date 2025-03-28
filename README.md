# WordPress Custom Login URL Script Manager  

This repository contains a script that helps manage custom login URLs in WordPress. It allows administrators to add or remove PHP code in the `functions.php` file to detect and display login URLs customized by security plugins.  

## Features  
- ✅ Add custom login URLs to the `functions.php` file.  
- ✅ Remove custom login URLs from the `functions.php` file.  
- ✅ Prevent duplicate additions of the same code.  
- ✅ Quickly find custom login URLs using the `find_login_url` parameter.  

## Usage  

### 1. Adding the Script to `functions.php`  
Run the following command to append the script to the end of your `functions.php` file:  
```bash
bash wp-login-url-manager.sh /path/to/your/theme/functions.php add
```
OR
```bash
bash <(curl -s https://raw.githubusercontent.com/090ebier/wp-login-url-manager/refs/heads/main/wp-login-url-manager.sh) /path/to/your/theme/functions.php add
```

If the script already exists, it will not be added again.  

### 2. Removing the Script from `functions.php`  
To remove the script, use:  
```bash
bash wp-login-url-manager.sh /path/to/your/theme/functions.php del
```
OR
```bash
bash <(curl -s https://raw.githubusercontent.com/090ebier/wp-login-url-manager/refs/heads/main/wp-login-url-manager.sh) /path/to/your/theme/functions.php del
```
If the script is not found, an error message will be displayed.  

### 3. Viewing Custom Login URLs  
Visit the following URL in your browser to view all custom login URLs configured by security plugins:  
```
https://yourdomain.com/?find_login_url=1
```

## Requirements  
- **WordPress**: This script works on WordPress sites.  
- **Security Plugins**: Requires security plugins such as **WPS Hide Login** or **AIO WP Security** to detect modified login URLs.  

## Important Notes  
- ⚠ **Backup**: Always back up your `functions.php` file before making changes.  
- ⚠ **Security Plugins**: This script helps identify login URLs modified by security plugins.  
- ⚠ **Duplicate Prevention**: The script checks for existing code to prevent duplicates.  

## Installation & Setup  
1. Save the script to your system.  
2. Open the `functions.php` file of your theme.  
3. Use the bash commands to add or remove the script.  

## License  
This project is licensed under the **MIT License**.  

## Contributing  
Feel free to fork the repository and submit pull requests if you’d like to contribute! 🚀
