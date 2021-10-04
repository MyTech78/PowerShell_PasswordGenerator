<#
.SYNOPSIS
 	
	Password Generator

.DESCRIPTION

  	This PS Script will genarate random password as select per crteria 
		
.INPUTS
	
	None

.OUTPUTS
	
	Random Password

.NOTES
	
	Version:        0.2
	Author:         Filipe Soares
	Github Repo:	https://github.com/MyTech78
	Creation Date:  04/10/2021
	Purpose/Change: 0.1 - Initial script development
                    0.2 - Added error handeling for number of characters (invaled number)
                          Added minumin characters number, and maximum amount of characters
                          warning option
                          Changed default characters number from 6 to 8
                          configured all options boxes enabled 
  
.EXAMPLE
  
    Run GUI Interface

	.\PasswordGenerator.ps1
	
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$XAML
)

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Setup and Load WPF XAML Form 
Function loadDialog {

	[CmdletBinding()]
	Param(
 	[Parameter(Mandatory=$True,Position=1)]
 	[string]$XamlPath
	)
	
    # calculate XAML full path
	$xamlPath = Join-Path -Path $PSScriptRoot -ChildPath $xamlPath
    # Import XAML content
	$inputXML = Get-Content -Path $XamlPath
    # clean XAML from Visual Studio to use with Windows Pwershell
    $inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
    # Convert to xml object
    [xml]$Global:xmlWPF = $inputXMLClean

	#Add WPF and Windows Forms assemblies
	try{

 	Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms

	} catch {

 	Throw "Failed to load Windows Presentation Framework assemblies."

	}

	#Create the XAML reader using a new XML node reader
	$Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

	#Create hooks to each named object in the XAML creatig PowerShell variables with their names
	$xmlWPF.SelectNodes("//*[@Name]") | %{
 	Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global

 	}
}

# Get Random Password Function
function RandomPassword {



    while (-not($resultOk)) {
    $resultOk = $True
        $result  = @()

        for ($i = 0; $i -lt $charNum; $i++) {
    
            if ($UpperCase -eq $true) {
                $U = [char[]]([int][char]'A'..[int][char]'Z') | Get-Random 
            }
            else {
                $u = $null
            }
            if ($LowerCase -eq $true) {
                $L = [char[]]([int][char]'a'..[int][char]'z') | Get-Random 
            }
            else {
                $L = $null
            }
            if ($Numbers -eq $true) {
                [string]$N = Get-Random -Maximum 10
            }
            else {
                $N = $null
            }
            if ($specialChar -eq $true) {
                $S = [char[]](33..47),[char[]](60..64),[char[]](93..95),[char[]](123..126),[char](91) | Get-Random
            }
            else {
                $S = $null
            }
        
            $r = $U+$L+$S+$N

            $a = $r.ToCharArray() | Get-Random

            $result += $a

        }
            $result = -join $result
    
            if ($UpperCase -eq $true) {
                if (-not ($result -cmatch '[A-Z]')) {
                    $resultOk = $false
                }
             }
            if ($LowerCase -eq $true) {
                if (-not ($result -cmatch '[a-z]')) {
                    $resultOk = $false
                    }
            }
            if ($Numbers -eq $true) {
                if (-not ($result -cmatch '[0-9]')) {
                    $resultOk = $false
                    }
            }
            if ($specialChar -eq $true) {
               if (-not ($result -cmatch "[#-/]" -or $result -cmatch "[<-@]" -or $result -cmatch "[]]" -or $result -cmatch "[[-_]" -or $result -cmatch "[{-~]" )) {
                    $resultOk = $false
                    }
            }

    }


    return $result
 }

 # Load app settings 
 Function LoadSettings {

    [int]$Global:charNum = $TB_charNum.Text
    $Global:upperCase = $CB_upperCase.IsChecked
    $Global:lowerCase = $CB_lowerCase.IsChecked
    $Global:specialChar = $CB_specialChar.IsChecked
    $Global:numbers = $CB_numbers.IsChecked
}

# Check for minimum amount of characters
 function MinChar {
            if ($UpperCase -eq $true) {
                $t1 = 1
            }
            else {
            $t1 = $null
            }
            if ($LowerCase -eq $true) {
                $t2 = 1
            }
                        else {
            $t2 = $null
            }
            if ($Numbers -eq $true) {
                $t3 = 1
            }
                        else {
            $t3 = $null
            }
            if ($specialChar -eq $true) {
                $t4 = 1
            }
                        else {
            $t4 = $null
            }

        return $t1+$t2+$t3+$t4
 }

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# load the XAML WPF Form File to be used with the script
if ($XAML) {
	loadDialog $XAML
}
else {
	loadDialog '.\XAML\MainWindow.xaml'	
}

#------------------------------------------------------------[Variables]-----------------------------------------------------------

#----------------------------------------------------------[EVENT Handler]---------------------------------------------------------
    
# click event for the Generate button 
$BT_generate.add_Click({ 
        
        # load selected settings to variables
        try {
            LoadSettings -ErrorAction Stop
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("$_","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        }
        
        # Check for minimum amount of characters
        $minChar = MinChar
        if ($charNum -lt $minChar) {
             [System.Windows.Forms.MessageBox]::Show("You selected to generate a password with $charNum characters, but you have $minChar complexity options selected !","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        }
        elseif ($charNum -gt 10000) {
            $options = [System.Windows.Forms.MessageBox]::Show("Realy, $charNum characters ! Ok but if it freezes it's not my fault.","Warning",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Warning)

            if ($options -eq "ok") {
                $TB_result.Text = RandomPassword
            }
            else {
            
            }
           
        }
        else {
            $TB_result.Text = RandomPassword
        }


   })

    # click event for the Copy button 
$BT_copy.add_Click({
        # Load current text in the Password text box to the clipboard
        $TB_result.Text | clip

   })

   # Text change event to calculate the amount of characters
$TB_result.Add_TextChanged({
        # load the calculation the length of the Password text box
        $TB_nChar.Text = $TB_result.Text.Length
    })


#------------------------------------------------------------[Show GUI]------------------------------------------------------------

#Launch the wpf form to windows
$xamGUI.ShowDialog() | out-null
