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
insert into ksiazki values(new ksiazka('przykladowy autor2', 'tytul2', 600, to_date('2017-05-30'), 200, 15, (select ref(a) from czytelnicy a where a.imie='imie1'));

select * from ksiazki;
select p.czytelnikref.imie, p.czytelnikref.nazwisko from ksiazki p;

--zad6

--select o.autor, o.tytul, deref(o.czytelnikref) from ksiazki o;
select o.autor, o.tytul, o.czytelnikRef.imie, o.czytelnikRef.nazwisko from ksiazki o;
select o.autor, o.tytul, deref(o.czytelnikRef) from ksiazki o;

--zad7
delete from czytelnicy p where p.imie='imie2';

--select * from ksiazki k where k.czytelnikRef is dangling;
update ksiazki k set k.czytelnikRef=null where k.czytelnikRef is dangling;

--zad8
create or replace type przedmTyp as varray(5) of varchar2(255);

create or replace type zad8 as object
(
  przedmioty przedmTyp
);

create table zad8TabObj of zad8;
insert into zad8TabObj values(new zad8(new przedmTyp('przedmiot1','przedmiot2', 'przedmiot3')));
insert into zad8TabObj values(new zad8(new przedmTyp('przedmiot4','przedmiot5', 'przedmiot6')));

declare
  test2 przedmTyp;
begin
  test2:=new przedmTyp('test1','test2');
  test2.extend(2);
  test2(3):='nowy element';
  test2(test2.last):='nowy element2';
  for ii in test2.first()..test2.last() loop
    dbms_output.put_line(test2(ii));
  end loop;
end;

--zad9
create type zad9Type as varray(50) of numeric(3,2);
create type studentType as object
(
  index1 number(4,0),
  nazwisko varchar2(50),
  oceny zad9Type
);

create table studenci of studentType;
insert into studenci values(new studentType(1,'student1',zad9Type(2,3,4,5)));
insert into studenci values(new studentType(1,'student2', new zad9Type(2,3,4,5)));

select * from studenci;

update studenci set oceny=zad9Type(2,2,2) where nazwisko='student2';

--zad10

--zad11
create type zad11Type as table of varchar2(255);
create type klient as object
(
  filmy zad11Type,
  nazwisko varchar2(50)
);
create or replace table klientTab of klient nested table filmy store as storageTabName1;

insert into klientTab values(new klient(new zad11Type('film1','film2'),'kowalski'));

select value(x) from table(select filmy from klientTab where nazwisko='kowalski') x;
insert into table(select filmy from klientTab where nazwisko='kowalski') values('film4324');
update table(select filmy from klientTab where nazwisko='kowalski')x where value(x)='film4324' set value(x)='test';
delete from table(select filmy from klientTab where nazwisko='kowalski')x where value(x)='film4324';

--zad12
select nazwisko, value(x) from klientTab cross join table(filmy) x;

