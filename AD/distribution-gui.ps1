#Allows you to create a distribution box from the AD.
#You need to have RSAT on your laptop
#Don't forget to edit line 58 for your AD domain

# IImport the necessary modules
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms

# Create the window
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Create a distribution group'
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = 'CenterScreen'

# Add fields for the name, alias and email
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Nom:'
$form.Controls.Add($label)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(10,40)
$textBox1.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,70)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = 'Alias:'
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox  # Correction ici
$textBox2.Location = New-Object System.Drawing.Point(10,90)
$textBox2.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,120)
$label3.Size = New-Object System.Drawing.Size(280,20)
$label3.Text = 'Email:'
$form.Controls.Add($label3)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10,140)
$textBox3.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox3)

# Add a button to create the group
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(10,170)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.Add_Click({
    $Nom = $textBox1.Text
    $Alias = $textBox2.Text
    $Email = $textBox3.Text
    try {
        $groupe = New-ADGroup -Name $Nom -SamAccountName $Alias -GroupCategory Distribution -GroupScope Global -DisplayName $Nom -Path "OU=Distributions,DC=exemple,DC=com" -Description "Distribution group for $Nom" -PassThru
        Set-ADGroup $groupe -Replace @{mail=$Email}
        [System.Windows.Forms.MessageBox]::Show("The distribution group was successfully created.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $form.Close()
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while creating the distribution group. Error details : $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($OKButton)

# Afficher la fenêtre
$form.ShowDialog()