Add-Type -AssemblyName System.Windows.Forms

# Crée une nouvelle fenêtre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Get LAPS Password"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = "CenterScreen"

# Crée un label pour demander le nom de l'ordinateur
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter name computer:"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($label)

# Crée une textbox pour entrer le nom de l'ordinateur
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Size = New-Object System.Drawing.Size(360, 20)
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$form.Controls.Add($textBox)

# Crée un bouton pour obtenir le mot de passe
$button = New-Object System.Windows.Forms.Button
$button.Text = "Get Password"
$button.Size = New-Object System.Drawing.Size(120, 30)
$button.Location = New-Object System.Drawing.Point(10, 80)
$form.Controls.Add($button)

# Crée un textblock pour afficher le résultat
$resultTextBox = New-Object System.Windows.Forms.TextBox
$resultTextBox.Multiline = $true
$resultTextBox.Size = New-Object System.Drawing.Size(360, 80)
$resultTextBox.Location = New-Object System.Drawing.Point(10, 120)
$form.Controls.Add($resultTextBox)

# Définir la fonction pour le clic du bouton
$button.Add_Click({
    $computerName = $textBox.Text
    if (![string]::IsNullOrEmpty($computerName)) {
        try {
            $passwordInfo = Get-LapsADPassword $computerName -AsPlainText
            $password = $passwordInfo.Password
            $resultTextBox.Text = "$password"
        } catch {
            $resultTextBox.Text = "Error: $($_.Exception.Message)"
        }
    } else {
        $resultTextBox.Text = "Please enter a computer name."
    }
})

# Affiche la fenêtre
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()