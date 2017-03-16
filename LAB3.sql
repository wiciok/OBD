set serveroutput on;


--zestaw3
--zad1

ACCEPT x prompt 'wprowadz imie';
ACCEPT y prompt 'wprowadz nazwisko';
DECLARE
  imie varchar2(20);
  nazwisko varchar2(20);
  liczba number(5);
BEGIN
  imie:='&x';
  nazwisko:='&y';
  
  SELECT COUNT(*)
  into liczba
  from zajecia
  where zajecia.id_wykladowca=
    (select id_wykladowca
    from wykladowca
    where 
      wykladowca.imie=imie
      and wykladowca.nazwisko=nazwisko
    fetch first row only);
  DBMS_OUTPUT.PUT_LINE(liczba);
END;


--lpad, rpad - wyrównanie

--zad2
DECLARE
  CURSOR kursor IS
    SELECT IMIE, NAZWISKO, NRALBUMU
    FROM STUDENT
    ORDER BY NRALBUMU desc;
  stud STUDENT%ROWTYPE;
  
BEGIN
  
  /*FOR ii IN kursor LOOP
    dbms_output.put_line(rpad(stud.imie, 15,'.') || RPAD(stud.nazwisko, 15, '.'))
  END LOOP;*/
  
  OPEN kursor;
  LOOP
    FETCH kursor INTO stud.imie, stud.nazwisko, stud.nralbumu;
    dbms_output.put_line(rpad(stud.imie, 15,'.') || RPAD(stud.nazwisko, 15, '.') || stud.nralbumu);
    EXIT WHEN kursor%NOTFOUND;
  END LOOP;
  CLOSE kursor;
END;

--zad3
DECLARE
  input_nralbumu NUMBER(10):=&dane_nralbumu;
  input_budynek VARCHAR2(40):='&dane_budynek';
  input_nrsali NUMBER(5):=&dane_nrsali;
  ilosc NUMBER(4);
BEGIN
  SELECT COUNT
  (
    --nie dziala poprawnie ten select
    SELECT id_zajecia 
    from ZAJECIA
    WHERE student.id_grupa=zajecia.id_grupa
    and student.nralbumu=input_nralbumu
    and sala.id_budynek=budynek.id_budynek
    and zajecia.id_sala=sala.id_sala
    and zajecia.kodsali=input_nrsali
    and budynek.nazwa=input_budynek
  )
  INTO ilosc
  dbms_output.put_line(ilosc);
END;

SELECT STUDENT.NRALBUMU, SALA.kodsali, BUDYNEK.NAZWA
FROM STUDENT, SALA, BUDYNEK, ZAJECIA
WHERE student.id_grupa=zajecia.id_grupa
    and sala.id_budynek=budynek.id_budynek
    and zajecia.id_sala=sala.id_sala;




