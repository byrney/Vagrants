
use master
go

create login vagrant with password = 'vagrant'
go

if db_id('delta') is null
    create database delta
go

use delta
go

create user vagrant for login vagrant;
go

EXEC sp_addrolemember N'db_owner', N'vagrant'

go


