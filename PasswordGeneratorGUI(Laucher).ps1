Function GetRootPath ($x) {
	$Path = $PSScriptRoot
	Join-Path -Path $Path -ChildPath $x
}
$psFile = GetRootPath -x "\bin\PasswordGeneratorGUI.ps1"

powershell.exe -WindowStyle Hidden -file $psFile