# PowerShell Twitter Search Automation

This PowerShell script automates Twitter searches for specific terms using Selenium WebDriver. It allows you to search for tweets based on a chosen term and interact with the search results.

## Requirements

- Windows OS
- PowerShell
- Internet connection

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/SleepTheGod/Powershell-Twitter.git
```
2. Install Selenium Module
Run the script in an elevated PowerShell session to install the Selenium module:
```ps1
Install-Module -Name Selenium.WebDriver
```
3. Download ChromeDriver
The script will automatically check for ChromeDriver. If not found, it will download and install it in C:\Windows\System32\.

Usage
Open PowerShell.
Navigate to the directory containing the script:
```bash
cd path/to/twitter-search-automation
```
Run the script:
```ps1
.\twitter_search.ps1
```
Follow the prompts:
Enter your Twitter search term (without #).
Choose whether to run the browser in headless mode (y/n).
The script will start a Chrome browser, securely log in to Twitter (prompting for credentials if not stored), perform the search, and display the extracted tweet texts.

Secure Login
The script utilizes Windows Credential Manager to securely store and retrieve Twitter credentials. It prompts for credentials if not stored, ensuring secure login automation.
```curl
curl -u "YOUR_API_KEY:YOUR_API_SECRET_KEY" "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=<USERNAME>&count=10"

```

Troubleshooting
If the script encounters issues during ChromeDriver installation, check your internet connection or try running the script again.
Ensure proper internet connectivity for successful Twitter login and search.
Notes
Adjust waiting times in the script (e.g., Start-Sleep -Seconds 5) based on network speed and site behavior.
Make sure to keep your stored credentials (TwitterCredentials) secure.
Disclaimer
This script is for educational purposes and assumes user consent and responsibility for automated interactions on Twitter.

Contributions
Contributions and improvements are welcome! Feel free to fork the repository, make changes, and submit a pull request.

License
This project is licensed under the MIT License.

Feel free to tailor the instructions, add or remove sections, and adjust the content to best suit your project and audience.
