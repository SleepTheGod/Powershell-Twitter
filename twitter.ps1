# Function to retrieve stored credentials securely
function Get-StoredCredentials {
    $credential = Get-Credential -Message "Enter your Twitter credentials"
    $credPath = "TwitterCredentials"
    $credential | Export-Clixml -Path $credPath
    return $credential
}

# Check for Selenium and download ChromeDriver if needed
try {
    if (!(Test-Path -Path "C:\Windows\System32\chromedriver.exe")) {
        Install-Module -Name Selenium.WebDriver -ErrorAction Stop
        Write-Host "Downloading and installing ChromeDriver..."

        $chromeDriverUrl = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE"
        $latestVersion = Invoke-WebRequest -Uri $chromeDriverUrl | Select-Object -ExpandProperty Content
        $chromeDriverDownloadUrl = "https://chromedriver.storage.googleapis.com/$latestVersion/chromedriver_win32.zip"

        $downloadPath = "C:\temp\chromedriver.zip"
        Invoke-WebRequest -Uri $chromeDriverDownloadUrl -OutFile $downloadPath

        Expand-Archive -Path $downloadPath -DestinationPath "C:\temp\"
        Copy-Item -Path "C:\temp\chromedriver.exe" -Destination "C:\Windows\System32\" -Force
        Remove-Item -Path $downloadPath -Force
        Write-Host "ChromeDriver installed!"
    }
} catch {
    Write-Error "Failed to download/install ChromeDriver. Please check your internet connection or try again later."
    exit
}

# Start Chrome browser
try {
    $options = New-Object Selenium.WebDriver.Chrome.ChromeOptions
    $driver = New-Object Selenium.WebDriver.Chrome -Options $options
} catch {
    Write-Error "Failed to start Chrome browser. Please ensure it's installed and accessible."
    exit
}

# Securely retrieve stored credentials or ask for them if not stored
$storedCredential = $null
$credPath = "TwitterCredentials"
if (Test-Path $credPath) {
    $storedCredential = Import-Clixml -Path $credPath
}

if ($storedCredential -eq $null) {
    $storedCredential = Get-StoredCredentials
}

# Use stored credentials to log in to Twitter
$username = $storedCredential.UserName
$password = $storedCredential.GetNetworkCredential().Password

try {
    $driver.Navigate().GoToUrl("https://twitter.com/login")
    Start-Sleep -Seconds 5  # Wait for page load

    $usernameField = $driver.FindElementByCssSelector('input[name="session[username_or_email]"]')
    $usernameField.SendKeys($username)

    $passwordField = $driver.FindElementByCssSelector('input[name="session[password]"]')
    $passwordField.SendKeys($password)

    $loginButton = $driver.FindElementByCssSelector('div[data-testid="LoginForm_Login_Button"]')
    $loginButton.Click()
    Start-Sleep -Seconds 5  # Wait for login

    if ($driver.Url -ne "https://twitter.com/login") {
        Write-Host "Login successful!"
    } else {
        throw "Login failed"
    }
} catch {
    Write-Error "Failed to login. Check your credentials or network connection."
    $driver.Quit()
    exit
}

# Get user input and handle errors
$searchTerm = Read-Host "Enter your Twitter search term (without #):"
if ($searchTerm -eq "") {
    Write-Error "Please enter a valid search term."
    $driver.Quit()
    exit
}

$headlessMode = Read-Host "Run browser in headless mode? (y/n):"
if ($headlessMode -match "^y|Y$") {
    $headlessMode = $true
} else {
    $headlessMode = $false
}

# Set Chrome options
if ($headlessMode) {
    $options.AddArgument("--headless")
}

# Search for tweets with hashtag and term
try {
    $searchField = $driver.FindElementByCssSelector("#search-query")
    $searchField.SendKeys("#$($searchTerm)")
    $submitButton = $driver.FindElementByCssSelector("#search-button")
    $submitButton.Click()
    Start-Sleep -Seconds 5  # Wait for search results
} catch {
    Write-Error "Failed to search for tweets. Check your internet connection or Twitter login."
    $driver.Quit()
    exit
}

# Extract and display tweet text
try {
    $results = $driver.FindElementsByCssSelector(".js-tweet-text")
    Write-Host "Found tweets:"
    foreach ($result in $results) {
        Write-Host "- $($result.Text)"
    }
} catch {
    Write-Error "Failed to extract tweet text."
} finally {
    $driver.Quit()
}
