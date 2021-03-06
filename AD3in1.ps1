﻿Import-Module activedirectory
$repeat=1
while ($repeat -eq 1)
{
cls
$choice = Read-Host "Какой скрипт запустить?
1. Инфо из AD по имени УЗ (признак основной УЗ, информация о пароле)
2. Сброс пароля
3. Поиск по ФИО"
Switch($choice) {
    1{
    Write-Host("
employeeType = 2 - не основная УЗ. 
passwordLastSet - последняя дата смены пароля. 
passwordExpires = true - требуется сменить пароль
")
    $a=read-host "Введите имя УЗ"
    Write-Host("")
    Write-Host("DC1")
    Get-ADUser $a -Properties employeeType, PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp -Server DC1
    Write-Host("")
    Write-Host("DC2")
    Write-Host("")
    Get-ADUser $a -Properties employeeType, PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp -Server DC2
    }
    2{
Write-Host("Сброс пароля")
$user_name=read-host "Введите имя УЗ"
Write-Host("В каком домене учетная запись?")
$domen = Read-Host "1 - DC1
2 - DC2
"
if ($domen -eq 1)
{
Write-Host("")
$srv_name = "DC1"
$AD_name = Get-ADUser $user_name -Properties Name -Server $srv_name
Write-Host("")
}
else {
Write-Host("")
$srv_name = "DC2"
$AD_name = Get-ADUser $user_name -Properties Name -Server $srv_name
Write-Host("")
}
$pass_true=2;
while ($pass_true -eq 2) {
get-random -count 8 -input ([char[]]'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ123456789') | % -begin { $pass = $null } -process {$pass += [char]$_} -end {$pass} 
$pass_true = Read-Host("1 - пароль подходит
2 - сгенерировать ещё")
}
Write-Host("")
Write-Host("Сбросить пароль сотруднику "+$AD_name) 
Write-Host("на временный пароль "+$pass+"?")
$changepw = Read-Host "
1 - Да БЕЗ принудительной смены пароля
2 - Да С принудительной сменой пароля
3 - Не сбрасывать
"
if ($changepw -eq 1)  
{
Set-ADAccountPassword $user_name -server $srv_name -NewPassword (ConvertTo-SecureString -AsPlainText –String $pass -force) -Reset
Write-Host("")
Write-Host("Пароль сброшен БЕЗ принудительной смены")
$pass | Clip
}
elseif ($changepw -eq 2)  
{
Set-ADAccountPassword $user_name -server $srv_name -NewPassword (ConvertTo-SecureString -AsPlainText –String $pass -force) -Reset
Set-ADUser $user_name -server $srv_name -ChangePasswordAtLogon $True
Write-Host("")
Write-Host("Пароль сброшен С принудительной сменой")
$pass | Clip
}
else {
Write-Host("")
Write-Host("Пароль не сброшен")
}
Write-Host("")
Write-Host("Какой шаблон письма использовать?")
$text_mail=Read-Host("1 - Новый сотрудник
2 - Разблокировка/Изменение
3 - Разблокировка/Изменение + инструкция по смене пароля на удаленке
4 - Никакой
")
if ($text_mail -eq 2) 
{
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.Subject = "Разблокировка учетной записи / изменение пароля"
$Mail.HTMLBody = '<span style=font-size:12.0pt;font-family:"Times New Roman","serif"><p>Здравствуйте!</p>
<p></p>
<p>Учетная
запись <b>'+$AD_name.Name+'</b> разблокирована, данные на вход в систему</span></p>
Имя пользователя:&emsp;&emsp;<b>'+$user_name+'</b><br>
Пароль:&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<b>'+$pass+'</b><p><b style=color:red>ВАЖНО!</b> При первом входе в систему потребуется произвести изменение пароля.
Длина пароля должна составлять не менее 8 символов, а сам пароль должен содержать
в себе как минимум одну заглавную букву и одну цифру. Ввод ранее используемых
паролей неприемлем, так как система не примет такой пароль повторно!</p>'
$Mail.Display()
}
elseif ($text_mail -eq 1)
{
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.Subject = "Новый сотрудник - Изменение пароля"
$Mail.HTMLBody = '<span style=font-size:12.0pt;font-family:"Times New Roman","serif"><p>Здравствуйте!</p>
<p></p>
<p>Данные на вход в систему сотрудника <b>'+$AD_name.Name+'</b></span><br>
Имя пользователя:&emsp;&emsp;<b>'+$user_name+'</b><br>
Пароль:&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<b>'+$pass+'</b><p><b style=color:red>ВАЖНО!</b> При первом входе в систему потребуется произвести изменение пароля.
Длина пароля должна составлять не менее 8 символов, а сам пароль должен содержать
в себе как минимум одну заглавную букву и одну цифру. Ввод ранее используемых
паролей неприемлем, так как система не примет такой пароль повторно!</p>'
$Mail.Display()
}
elseif ($text_mail -eq 3)
{
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.Subject = "Разблокировка учетной записи / изменение пароля"
$Mail.Attachments.Add("ПУТЬ ДО ФАЙЛА-ИНСТРУКЦИИ. Как вложение в письмо вставляется")
$Mail.HTMLBody = '<span style=font-size:12.0pt;font-family:"Times New Roman","serif"><p>Здравствуйте!</p>
<p></p>
<p>Учетная
запись <b>'+$AD_name.Name+'</b> разблокирована, данные на вход в систему</span></p>
Имя пользователя:&emsp;&emsp;<b>'+$user_name+'</b><br>
Пароль:&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<b>'+$pass+'</b><p><b style=color:red>ВАЖНО! </b>После подключения к удаленному рабочему столу необходимо сменить пароль.
Для этого воспользуйтесь инструкцией во вложении.</p>'
$Mail.Display()
}
}
3{
$searchname = Read-Host "ФИО для поиска" + "* в конце"
Write-Host("DC1")
Get-ADUser -filter {name -like $searchname} -Server DC1 -Properties Name, SamAccountName, DistinguishedName, PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp, lockedout, employeeType | Select Name, SamAccountName, DistinguishedName, PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp, lockedout, employeeType | fl
Write-Host("DC2")
Get-ADUser -filter {name -like $searchname} -Server DC2 -Properties Name, SamAccountName, DistinguishedName, PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp, lockedout, employeeType | Select Name, SamAccountName, DistinguishedName, PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp, lockedout, employeeType | fl
}}
$repeat=Read-Host("1 - Повторить
2 - Закрыть")
}