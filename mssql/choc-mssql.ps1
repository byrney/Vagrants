choco feature enable -n=allowGlobalConfirmation

write-host "Microsoft SQL Server Express"
choco install -y --force mssql2014express-customized -source 'c:\vagrant'
choco install sql2008r2.cmdline

