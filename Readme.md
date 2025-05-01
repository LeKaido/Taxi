
+ Installatsioon

1. Tee localhosti tühi postgre baas nimega taxi, parooliks pane SalaKala123#
2. Käivita Sql\TaxiBb.sql et baas sisustada

Fail https://www.kaggle.com/datasets/adelanseur/taxi-trips-chicago-2024
tõmba alla ja paiguta kataloogi C:\temp\Taxi\RawData\Full

Koodi käivitamiseks ava esmalt Visual Studioga solution (Taxi.sln) ja tee sellele build.

+ Faili tükeldamine 
 
TaxiSplit\bin\debug\TaxiSplit.exe käivitus peaks tükeldama põhifaili nädalasteks
ja paigutama tükid kataloogi C:\temp\Taxi\RawData\Weekly

+ Faili laadimine

TaxiLoad\bin\Debug\TaxiLoad.exe käivitus peaks nädalased tükid baasi laadima tabelisse taxi.taxirides

+ Mudeli tegemine

ShifModel.sql -i käivitamine peaks tegema vahetuste mudeli üle kõigi laetud kirjete
taxi.taxirides -> taxi.shiftmodel

+ Mudeli inkrementaalne uuendamine

Sellega kaugele ei jõudnud.
Idee on üldiselt selline, et peaks eeldama, et igasse andmelõiku võib tulla uuendusi või täiendusi.


Seega algoritm võiks umbes selline olla, et 
1. Võtta baasandmetest juurde tulnud osast kõik või esimene osa uuenduse aja järgi.
2. Võtta mudelist baasandmete valitud osale vastav kogus kirjeid (ajaliselt periood ja/või taxiid-ga piiratud)
3. Korrutada ajaliselt 15-minutisteks perioodideks mõlemad pooled, dedubleerida
4. Panna kokku uuenduse pakett, kustutada valitud osast id järgi maha, mis enam ei peaks olema, insertida asemele uus osa 

ModelMerge.sql -is võib näha katsetusi aga see algoritmi kontroll vajab tugevat test-case ja seda praegu ei jõudnud teha.


