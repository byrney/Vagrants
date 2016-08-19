
The base box has this isue:

https://github.com/chef/bento/issues/609

which can be fixed by doing this

    sudo systemctl disable apt-daily.service # disable run when system boot
    sudo systemctl disable apt-daily.timer   # disable timer run


Ideally we would get this fixed upstream, but it's not clear that the
maintainer was actually intending for others to reuse his work...


