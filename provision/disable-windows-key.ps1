# This prevents the guest from treating left CMD as windows key
# So you can use left CMD for virtualbox host key and right cmd 
# as the windows key in the guest
# regedit -s \vagrant\disable-windows-key.reg

Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
 -name "Scancode Map" `
 -value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x5b,0xe0,0x00,0x00,0x00,0x00))

