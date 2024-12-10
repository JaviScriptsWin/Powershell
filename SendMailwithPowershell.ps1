# 12/2025 Script powershell para mandar correo empleando la cuenta de Gmail

$CredUser       = "tudirecciongmail@gmail.com"
$CredPassword   = " Te la facilita Gmail en: ‘Contraseñas de aplicación’ de tu Cuenta de correo"
$EmailFrom      = " tudirecciongmail@gmail.com"
$EmailTo        = " tudirecciongmail@gmail.com"
$Subject        = "Asunto del mensaje desde: $env:computername "
$Body           = "Mensaje de prueba desde $env:computername usuario: $env:username"
$SMTPServer     = "smtp.gmail.com"
$SMTPClient     = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl     = $true
$SMTPClient.Credentials   = New-Object System.Net.NetworkCredential($CredUser, $CredPassword)
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)


<# ---------------------------------------
La contraseña te la facilita Gmail cuando le indicas qué aplicación vas a emplear para mandar el correo  empleando Gmail:
- Debes activar la verificación de dos pasos.
- Crear contraseña de Aplicación, añadiendo la Aplicación que se vaya a emplear y copiando la contraseña
que te de Gmail en la Aplicación o Script que vayas a emplear. Este método implica que deberemos
guardar el script en un sitio innacesible para los usuarios normales.
on en el buscador dentro de tu cuenta de Gmail: ”contraseñas de aplicación” y añade la aplicación que vas a
usar para que te asignen una contraseña.

Más información: https://support.google.com/accounts/answer/185833

En un futuro quizá debamos emplear Send-MailKitMessage un reemplazo para el obsoleto SendMailMessage de PowerShell que implementa la biblioteca MailKit recomendada por Microsoft para mandar
correos desde Powershell. Tambien se debe configurar la cuenta de Outlook que empleemos y quizá el Office
365 online o el Azure Online.

https://www.powershellgallery.com/packages/Send-MailKitMessage/3.2.0
--------------------------------------------#>
