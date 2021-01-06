#!/bin/bash
#Vol 1

directory_exist(){
project_directory=~/PasswordKeeper
if [[ -d "$project_directory" ]]; then
login
else
setup
fi
}

admin_area(){
echo "This is admin area"
sleep 4
return
}

user_area(){
echo "This is user area"
sleep 4
return
}

login(){
echo ""

while true; do	
COLUMNS=$(tput cols)
title="$(tput setaf 6)CaksSonicDeveloper$(tput sgr 0)"
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
echo ""
title_1="$(tput setaf 6) PASSWORD KEEPER - LOGIN MENU$(tput sgr 0)"
printf "%*s\n" $(((${#title_1}+$COLUMNS)/2)) "$title_1"
echo ""
title_2="$(tput setaf 2)Welcome $USER$(tput sgr 0)"
printf "%*s\n" $(((${#title_2}+$COLUMNS)/2)) "$title_2"

echo ""

echo "$(tput setaf 2)Please Insert Your Credientials:$(tput sgr 0) "
echo ""
read -p  "Enter User Name: " name
echo ""
read -s -p "Enter password: " password
echo ""
echo ""
echo ""

if [[ -z "$name" ]] || [[ -z "$password" ]]; then
echo "$(tput setaf 1)WARNNING: Blank User Name or Password Not Alllowed$(tput sgr 0)"
sleep 2
clear
login
else
cat << _EOF_

 ____________
|            |
| 1. Login   |
|            |
| 0. Quit    |
|____________|

_EOF_


echo ""
read -p "Enter selection [0 - 1] > "
echo ""

if [[ $REPLY =~ ^[0-1]$ ]];then
case $REPLY in


1)
cd ~/PasswordKeeper
 
#test_1=$(sqlite3 pk.db "SELECT admin, admin_password from admin where admin='$name' and admin_password='$password';")
test=$(sqlite3 pk.db \ "
SELECT administrator.administrator, administrator.administrator_password, korisnici.admin, korisnici.admin_password
FROM korisnici
INNER JOIN administrator ON korisnici.fk_admin=fk_admin
WHERE administrator.administrator='$name'
AND administrator.administrator_password='$password'
AND korisnici.admin='$name'
AND korisnici.admin_password='$password'
;")

test_1=$(sqlite3 pk.db  "SELECT korisnik FROM korisnici where korisnik='$name';")
test_2=$(sqlite3 pk.db  "SELECT zaporka FROM korisnici where zaporka='$password';")
 
if [[ "$test" == *"$name|$password|$name|$password"* ]]; then
admin_area

elif [ "$test_1" == "$name" ] && [ "$test_2" == "$password" ]; then
user_area

else
echo "$(tput setaf 1)WARNNING: Incorrect User Name Or Password$(tput sgr 0)"
sleep 2
clear
login
fi



sleep 4
continue
;;

0)
break
;;
esac
else
echo "$(tput setaf 1)Invalid Entry"
sleep 3
clear
fi
fi
done
}

setup(){

echo ""
while true; do
COLUMNS=$(tput cols)
title="$(tput setaf 6)CaksSonicDeveloper$(tput sgr 0)"
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
echo ""
title_1="$(tput setaf 6) PASSWORD KEEPER - SETUP MENU$(tput sgr 0)"
printf "%*s\n" $(((${#title_1}+$COLUMNS)/2)) "$title_1"
echo ""
title_2="$(tput setaf 2)Welcome $USER$(tput sgr 0)"
printf "%*s\n" $(((${#title_2}+$COLUMNS)/2)) "$title_2"
echo ""
cat << _EOF_
$(tput setaf 4)Please Select:

 _________________
|                 | 
| 1. Continue     |
|                 |
| 0. Quit         |
|_________________|$(tput sgr 0)

_EOF_
echo ""
read -p "Enter selection [0-1] > "
echo ""

if [[ $REPLY =~ ^[0-1]$  ]]; then
case $REPLY in
1)
cat << _EOF_
$(tput setaf 4)Welcome To Password Keeper Application
Program Will Create Necessary Directory, Database And Admin User
Please Be Patient$(tput sgr 0)
_EOF_
echo ""
read  -t 600 -n 1 -r -s -p $'Press Any Key To Continue ....\n'
echo ""
mkdir ~/PasswordKeeper
project_directory=~/PasswordKeeper
if [[ -d "$project_directory"  ]]; then
#echo "$(tput setaf 2)Success: Directory Is Created - Directory Path Is:$(tput sgr 0) $(tput setaf 1)$project_directory$(tput sgr 0)"
#sleep 3
echo ""
else
echo "$(tput setaf 1)Error: Directory Did Not Created - Program Terminated$(tput sgr 0)"
sleep 3
exit 0
fi
#echo "$(tput setaf 4)Let's Create SQLite database$(tput sgr 0)"
#sleep 3

cd ~/PasswordKeeper/
# Ova naredba kreira praznu bazu podataka
sqlite3 pk.db ""

database_exist=~/PasswordKeeper/pk.db
if [[ -f "$database_exist"  ]]; then
#echo "$(tput setaf 2)Success: Database Is Created$(tput sgr 0)"
echo ""
#sleep 3
else
echo "$(tput setaf 1)Error: Database Is Not Created - Roll Back All$(tput sgr 0)"
sleep 3
echo "$(tput setaf 1)Program Is Terminated$(tput sgr 0)"
rm -rf ~/PasswordKeeper
exit 0
fi
sleep 2
###############################################################################
cd ~/PasswordKeeper
sqlite3 pk.db \ "
PRAGMA foreign_keys = ON;

CREATE TABLE racuni (
id  INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
ime_racuna VARCHAR(16)
);" 
cd ~/PasswordKeeper
racuni_table=$(sqlite3 pk.db '.tables')

if [[ "$racuni_table" == *"racuni"* ]]; then
#echo "$(tput setaf 2)Success: Table racuni created$(tput sgr 0)"
echo ""
else
echo "$(tput setaf 1)Error: Table Is Not Created - Roll Back All$(tput sgr 0)"
rm -rf ~/PasswordKeeper
exit 0
fi
###############################################################################
cd ~/PasswordKeeper
sqlite3 pk.db \ "
PRAGMA foreign_keys = ON;

CREATE TABLE administrator (
id  INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
administrator VARCHAR(16),
administrator_password VARCHAR(16)
);" 
cd ~/PasswordKeeper
administrator_table=$(sqlite3 pk.db '.tables')

if [[ "$administrator_table" == *"administrator"* ]]; then
#echo "$(tput setaf 2)Success: Table administrator created$(tput sgr 0)"
echo ""
else
echo "$(tput setaf 1)Error: Table Is Not Created - Roll Back All$(tput sgr 0)"
#sleep 3
rm -rf ~/PasswordKeeper
exit 0
fi

############################################################################
cd ~/PasswordKeeper
sqlite3 pk.db \ "
PRAGMA foreign_keys = ON;
CREATE TABLE korisnici (
id  INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
korisnik VARCHAR(16),
zaporka VARCHAR(16),
admin VARCHAR(16),
admin_password VARCHAR(16),

fk_admin INTEGER NOT NULL, 
fk_racuni INTEGER NOT NULL,

FOREIGN KEY (fk_admin) REFERENCES administrator (fk_admin),

FOREIGN KEY (fk_racuni) REFERENCES racuni (fk_racuni)
);" 

cd ~/PasswordKeeper
korisnici_table=$(sqlite3 pk.db '.tables')

if [[ "$korisnici_table" == *"korisnici"* ]]; then
#echo "$(tput setaf 2)Success: Table korisnici created$(tput sgr 0)"
echo ""
else
echo "$(tput setaf 1)Error: Table Is Not Created - Roll Back All$(tput sgr 0)"
sleep 3
rm -rf ~/PasswordKeeper
exit 0
fi

##########################################################################
cd ~/PasswordKeeper

sqlite3 pk.db \ "
PRAGMA foreign_keys = ON;

CREATE TABLE usluga (
id  INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
korisnik VARCHAR(16),
usluga VARCHAR(16),
korisnicko_ime VARCHAR(16),
zaporka VARCHAR(16),
link VARCHAR(16)
);" 

cd ~/PasswordKeeper
usluga_table=$(sqlite3 pk.db '.tables')

if [[ "$usluga_table" == *"usluga"* ]]; then
#echo "$(tput setaf 2)Success: Table usluga created$(tput sgr 0)"
echo ""
else
echo "$(tput setaf 1)Error: Table Is Not Created - Roll Back All$(tput sgr 0)"
sleep 3
rm -rf ~/PasswordKeeper
exit 0
fi

#######################################################################
cd ~/PasswordKeeper
sqlite3 pk.db \ "
INSERT INTO racuni (ime_racuna)
VALUES
('administrator');
INSERT INTO racuni (ime_racuna)
VALUES
('korisnici');"


#########################################################################
cd ~/PasswordKeeper
sqlite3 pk.db \ "
INSERT INTO administrator (id,administrator, administrator_password)
VALUES
('0','non_administrator', '');

INSERT INTO administrator (administrator, administrator_password)
VALUES
('administrator', '0000');

"
########################################################################

sqlite3 pk.db \ "
INSERT INTO korisnici (admin, admin_password, fk_admin, fk_racuni)
VALUES
('administrator', '0000', '1', '1');"

########################################################################
echo "$(tput setaf 2)Success: You Are Ready To Use PasswordKeeper$(tput sgr 0)"
echo ""
echo "$(tput setaf 2)Your User Name Is:$(tput sgr 0)" "$(tput setaf 1) admin$(tput sgr 0)"
echo ""
echo "$(tput setaf 2)Your Password Is:$(tput sgr 0)" "$(tput setaf 1) 0000$(tput sgr 0)"
echo ""
echo "$(tput setaf 1)Note: Later On You Can Change Deault User Name & Password$(tput sgr 0)"
echo ""

read  -t 600 -n 1 -r -s -p $'Press Any Key To Continue ....\n'
clear
directory_exist
continue
;;

0)
echo "$(tput setaf 1)Program Terminated$(tput sgr 0)"
sleep 2
exit 0
esac
else
echo "$(tput setaf 1)Invalid Entry$(tput sgr 0)"
sleep 2
clear
setup
fi
done
	
}

directory_exist
