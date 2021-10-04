<#
.SYNOPSIS
 	
	<Overview of script>

.DESCRIPTION

  	<Brief description of script>
	
.PARAMETER CSV

	This will generate a CSV File with the report.

.PARAMETER Email

	This will generate an Email with the report.
	Note: This option requires Dot Source supporting Function Library

.PARAMETER TXT

	This will generate a text file with the report.
	the information will be appended with a time stamp.
	
.PARAMETER Version

	This display the current Script version.
	
.INPUTS
	
	<Inputs if any, otherwise state None>

.OUTPUTS
	
	<Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
	
	Version:        0.1
	Author:         Filipe Soares
	Github Repo:	https://github.com/MyTech78
	Creation Date:  
	Purpose/Change: Initial script development
  
.EXAMPLE
  
	<Example goes here. Repeat this attribute for more than one example>
	
.EXAMPLE
  
	<Example goes here. Repeat this attribute for more than one example>
	
.EXAMPLE
  
	<Example goes here. Repeat this attribute for more than one example>
	
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
            $S = [char[]](33..47),[char[]](58..64) | Get-Random 
        }
        else {
            $S = $null
        }
        
        $r = $U+$L+$S+$N

        $a = $r.ToCharArray() | Get-Random

        $result += $a

    }

    $fresult = -join $result
    return $fresult
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
    [int]$charNum = $TB_charNum.Text
    $upperCase = $CB_upperCase.IsChecked
    $lowerCase = $CB_lowerCase.IsChecked
    $specialChar = $CB_specialChar.IsChecked
    $numbers = $CB_numbers.IsChecked
    # Load RandomPassword result to the Password text box
    $TB_result.Text = RandomPassword

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
