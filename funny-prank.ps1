# =============================================
# Funny But Harmless PowerShell Prank
# "AI Assistant Prank" - ASCII Version
# =============================================

Add-Type -AssemblyName System.Speech
Add-Type -AssemblyName PresentationFramework
$speechSynthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Function to display funny messages
function Show-FunnyMessage {
    param([string]$Message, [string]$Title = "AI Assistant")
    
    [System.Windows.MessageBox]::Show($Message, $Title, "OK", "Information") | Out-Null
}

# Function for text-to-speech (if available)
function Speak-Message {
    param([string]$Message)
    
    try {
        $speechSynthesizer.SpeakAsync($Message) | Out-Null
    }
    catch {
        # Silently continue if speech synthesis fails
    }
}

# Main prank execution
Clear-Host
Write-Host "Initializing AI Assistant..." -ForegroundColor Cyan

# Fun loading animation
for ($i = 1; $i -le 3; $i++) {
    Write-Host "Analyzing your personality... [$i/3]" -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

# Series of funny messages and interactions
Show-FunnyMessage "Hello! I'm your new AI Assistant. I've detected exceptional levels of awesome in this computer." "AI Assistant"

Speak-Message "Hello human! I am here to help."

Start-Sleep -Seconds 2

Show-FunnyMessage "Scanning system...`n`n- Detected: Expert-level computer user`n- Detected: Superior taste in humor`n- Detected: Magnificent typing skills" "System Analysis"

Speak-Message "Your computer skills are most impressive!"

Start-Sleep -Seconds 2

# Fun computer "analysis"
Show-FunnyMessage "I've optimized your system for:`n`n* 300% more productivity`n* 150% better jokes`n* Unlimited cat video viewing`n`nYou're welcome!" "Optimization Complete"

# Open some fun websites (harmless)
$websites = @(
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "https://alwaysjudgeabookbyitscover.com",
    "https://www.rainymood.com"
)

foreach ($site in $websites) {
    try {
        Start-Process $site
        Start-Sleep -Seconds 2
    }
    catch {
        # Continue if browser fails to open
    }
}

# Create a funny desktop message (using ASCII only)
$desktopPath = [Environment]::GetFolderPath("Desktop")
$messageFile = Join-Path $desktopPath "IMPORTANT_AI_MESSAGE.txt"

@"
=============================================
           IMPORTANT MESSAGE          
         FROM YOUR AI ASSISTANT       
=============================================

  Greetings, human!                  

  I have analyzed your system and    
  found it to be exceptionally       
  well-maintained and awesome!       

  Your computer is now optimized for:
  * 200% more productivity           
  * Unlimited entertainment          
  * Maximum comfort and joy          

  Continue being amazing!            

  Sincerely,                         
  Your Friendly AI Assistant

=============================================

P.S. This was a harmless prank! No changes were made to your system.
"@ | Out-File -FilePath $messageFile -Encoding ASCII

# Fun system "scan" animation
Write-Host "`nPerforming final system checks..." -ForegroundColor Green
$phrases = @(
    "Scanning processor...",
    "Analyzing memory...", 
    "Checking awesome levels...",
    "Optimizing fun settings...",
    "Finalizing upgrades..."
)

foreach ($phrase in $phrases) {
    Write-Host "$phrase" -ForegroundColor Cyan
    Start-Sleep -Milliseconds 800
}

# Final funny message
Show-FunnyMessage "Mission accomplished!`n`nYour computer has been successfully blessed with:`n`n* Enhanced awesomeness`n* Premium humor upgrade`n* Infinite patience for loading screens`n`nCheck your desktop for an important message!" "Mission Complete"

Speak-Message "All systems are go! Have a fantastic day!"

# Clean up speech synthesizer
try {
    $speechSynthesizer.Dispose()
}
catch {
    # Ignore disposal errors
}

Write-Host "`nPrank completed successfully! Check your desktop for a message." -ForegroundColor Green
Write-Host "This was completely harmless - no system changes were made." -ForegroundColor Yellow

# Wait a moment before exiting
Start-Sleep -Seconds 3
