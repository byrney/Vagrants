
install conda

install R from conda

Setup packrat


R Profile
-----

    vagrant@csc:~$ cat .Rprofile

    cat(".Rprofile: Setting UK repositoryn")
    r = getOption("repos") # hard code the UK repo for CRAN
    r["CRAN"] = "http://cran.uk.r-project.org"
    options(repos = r)
    rm(r)

R Env
---

    vagrant@csc:~$ cat .Renviron
    R_LIBS=/home/vagrant/.r_packages

Project
---

    vagrant@csc:~/r-play$ cat init

    install.packages("packrat")
    packrat::init(".", enter=FALSE)

