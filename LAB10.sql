SET SERVEROUTPUT ON;

--zestaw 10

--zad1
create or replace type KSIAZKA AS OBJECT
(
  autor varchar2(50),
  tytul varchar2(50),
  liczbaStron number(3,0),
  dataWydania date,
  cena number(3,0),
  liczbaWypozyczen number(4,0)
)

create table ksiazki of ksiazka;

insert into ksiazki values('przykladowy autor', 'tytul', 500, to_date('2017-05-31'), 100, 25);
insert into ksiazki values(new ksiazka('przykladowy autor2', 'tytul2', 600, to_date('2017-05-30'), 200, 15));

select * from ksiazki;
select value(p) from ksiazki p;

--zad2

create table biblioteki
(
  nazwa varchar2(50),
  adres varchar2(50),
  ksiazkaObj ksiazka
);

insert into biblioteki values('bibl1', 'adres1', new ksiazka('przykladowy autor2', 'tytul2', 600, to_date('2017-05-30'), 15));

select * from biblioteki;
select p.ksiazkaObj.tytul from biblioteki p;

--zad3
alter type ksiazka replace as object
(
  autor varchar2(50),
  tytul varchar2(50),
  liczbaStron number(3,0),
  dataWydania date,
  cena number(3,0),
  liczbaWypozyczen number(4,0),
  member function liczWartosc return number
);

create or replace type body ksiazka as
  member function liczWartosc return number is
    retVal number(10,5):=0;
    lata number(2);
  begin 
    lata:=extract(year from CURRENT_TIMESTAMP)-extract(year from dataWydania);
    retVal:=cena;
    
    for ii in 0..lata loop
      retVal:=retVal*0.95;
    end loop;
    return retVal;
  end;
end;

select p.tytul,p.liczWartosc() from ksiazki p;

--zad4
alter type ksiazka add map member function odwzoruj return number cascade including table data;

  create or replace type body ksiazka as
    member function liczWartosc return number is
      retVal number(10,5):=0;
      lata number(2);
    begin 
      lata:=extract(year from CURRENT_TIMESTAMP)-extract(year from dataWydania);
      retVal:=cena;
      
      for ii in 0..lata loop
        retVal:=retVal*0.95;
      end loop;
      return retVal;
  end;
  
  map member function odwzoruj return number is
    lata number(2);
  begin
    lata:=extract(year from CURRENT_TIMESTAMP)-extract(year from dataWydania);
    return lata*10;
  end;
end;

--zad5

create type czytelnik as object
(
  imie varchar2(50),
  nazwisko varchar2(50)
)

create type ksiazka as object
(
  autor varchar2(50),
  tytul varchar2(50),
  liczbaStron number(3,0),
  dataWydania date,
  cena number(3,0),
  liczbaWypozyczen number(4,0),
  czytelnikRef ref czytelnik,
  member function liczWartosc return number
);

create table czytelnicy of czytelnik;
insert into czytelnicy values(new czytelnik('imie1', 'nazwisko1'));
insert into czytelnicy values(new czytelnik('imie2', 'nazwisko2'));

--cos tu sa problemy jakeis dziwne

create table ksiazki of ksiazka;
--insert into ksiazki values('przykladowy autor', 'tytul', 500, to_date('2017-05-31'), 100, 25, ref(new czytelnik('imie3', 'nazwisko3')));
insert into ksiazki values(new ksiazka('przykladowy autor2', 'tytul2', 600, to_date('2017-05-30'), 200, 15, null));
insert into ksiazki values(new ksiazka('przykladowy autor2', 'tytul2', 600, to_date('2017-05-30'), 200, 15, select ref(a) from czytelnicy a where a.imie='imie1');

select * from ksiazki;
select p.czytelnikref.imie, p.czytelnikref.nazwisko from ksiazki p;

--zad6

--select o.autor, o.tytul, deref(o.czytelnikref) from ksiazki o;
select o.autor, o.tytul, o.czytelnikRef.imie, o.czytelnikRef.nazwisko from ksiazki o;

--zad7
delete from czytelnicy p where p.imie='imie2';

--select * from ksiazki k where k.czytelnikRef is dangling;
update ksiazki k set k.czytelnikRef=null where k.czytelnikRef is dangling;

--zad8

