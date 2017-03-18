--zestaw3
set serveroutput on;

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
  --to nie bo ma byæ wg. polecenia wykorzystane fetch
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
  input_budynek VARCHAR2(50):='&dane_budynek';
  input_kodsali varchar2(10):='&dane_kodsali';
  ilosc NUMBER(10);
BEGIN
  SELECT COUNT(*)
  INTO ilosc
  FROM 
  (
    --niepoprawne - zwraca za du¿o wyników
    /*SELECT id_zajecia 
    from ZAJECIA, SALA, BUDYNEK, GRUPA, student
    WHERE student.id_grupa=zajecia.id_grupa
    and student.nralbumu=input_nralbumu
    and sala.id_budynek=budynek.id_budynek
    and zajecia.id_sala=sala.id_sala
    and sala.kodsali=input_kodsali
    and budynek.nazwa=input_budynek*/
    
    SELECT id_zajecia 
    FROM 
      ZAJECIA 
      LEFT JOIN 
        (SALA LEFT JOIN BUDYNEK USING(ID_BUDYNEK)) 
        USING(ID_SALA) 
      LEFT JOIN 
        (GRUPA left JOIN STUDENT USING(ID_GRUPA))
        USING(ID_GRUPA)
    WHERE
      student.nralbumu=input_nralbumu
      AND sala.kodsali=input_kodsali
      AND budynek.nazwa=input_budynek
  );
  dbms_output.put_line(ilosc);
END;

--POMOCNICZY SELECT DO UZYSKANIA DANYCH
SELECT STUDENT.NRALBUMU, SALA.kodsali, BUDYNEK.NAZWA, zajecia.id_przedmiot, zajecia.id_zajecia
FROM STUDENT, SALA, BUDYNEK, ZAJECIA
WHERE student.id_grupa=zajecia.id_grupa
    and sala.id_budynek=budynek.id_budynek
    and zajecia.id_sala=sala.id_sala
    and student.nralbumu=90934
    order by nralbumu;


--zad4a
DECLARE
  CURSOR stud_cursor IS
    SELECT * FROM STUDENT;
  TYPE student_typ IS RECORD
  (
    ID_STUDENT NUMBER(4,0),
    IMIE VARCHAR2(20),
    NAZWISKO VARCHAR2(30),
    ID_ADRES NUMBER(4,0),
    NRALBUMU NUMBER (10,0),
    ID_GRUPA NUMBER(4,0)
  );
  student2 student_typ;
BEGIN
  OPEN stud_cursor;
  LOOP
    FETCH stud_cursor INTO student2;
    dbms_output.put_line(student2.nralbumu||' '||student2.imie || ' ' || student2.nazwisko);
    EXIT WHEN stud_cursor%NOTFOUND;
  END LOOP;
  CLOSE stud_cursor;
END;

--zad4B
DECLARE
  CURSOR stud_cursor IS
    SELECT * FROM STUDENT;
  student2 STUDENT%ROWTYPE;
BEGIN
  OPEN stud_cursor;
  LOOP
    FETCH stud_cursor INTO student2;
    dbms_output.put_line(student2.nralbumu||' '||student2.imie || '' || student2.nazwisko);
    EXIT WHEN stud_cursor%NOTFOUND;
  END LOOP;
  CLOSE stud_cursor;
END;

--zad4c
DECLARE
  CURSOR stud_cursor IS
    SELECT * FROM STUDENT;
BEGIN
  FOR ii IN stud_cursor LOOP
    dbms_output.put_line(ii.nralbumu||' '||ii.imie || ' ' || ii.nazwisko);
  END LOOP;
END;

--zad5
--dokonczyc

--brakuje jakiegos jednego zlaczenia
/*SELECT DISTINCT ocena.OCENA, ID_PRZEDMIOT, ID_STUDENT
FROM 
  ZAJECIA
  INNER JOIN 
  (
    STUDENT INNER JOIN GRUPA USING(ID_GRUPA)
    INNER JOIN OCENA USING(ID_STUDENT)
  )USING(ID_GRUPA);*/
  
SELECT DISTINCT OCENA, ZAJECIA.ID_PRZEDMIOT, OCENA.ID_STUDENT
FROM ZAJECIA, OCENA, STUDENT, GRUPA
WHERE 
  ZAJECIA.ID_GRUPA=GRUPA.ID_GRUPA
  AND STUDENT.ID_GRUPA=GRUPA.ID_GRUPA
  AND STUDENT.ID_STUDENT=OCENA.ID_STUDENT
  AND OCENA.ID_ZAJECIA=ZAJECIA.ID_ZAJECIA
  ORDER BY ID_PRZEDMIOT;
  

--ZAD6
--nie dziala
ACCEPT INPUT prompt 'wprowadz grupe';
DECLARE
  grupa_nazwa2 varchar2(30);
  grupa grupa.id_grupa%type;
  tmp_kod charakter.id_charakter%type;
  CURSOR my_cursor(przedmiot_nazwa varchar2) IS
    SELECT charakter.nazwa 
    FROM ZAJECIA
    LEFT JOIN PRZEDMIOT USING(ID_PRZEDMIOT)
    LEFT JOIN CHARAKTER USING(ID_CHARAKTER)
    WHERE PRZEDMIOT.NAZWA=przedmiot_nazwa;   
BEGIN
  grupa_nazwa2:='&input';
  FOR ii IN my_cursor(grupa_nazwa2) LOOP
    CASE
      WHEN ii.nazwa='Laboratoria' THEN
        SELECT ID_CHARAKTER FROM CHARAKTER INTO tmp_kod WHERE NAZWA='Wyk³ady';
        UPDATE zajecia SET id_charakter=tmp_kod WHERE CURRENT OF my_cursor;
      WHEN ii.nazwa='Wyk³ady' THEN
        SELECT ID_CHARAKTER FROM CHARAKTER INTO tmp_kod WHERE NAZWA='Æwiczenia';
        UPDATE zajecia SET id_charakter=tmp_kod WHERE CURRENT OF my_cursor;
      WHEN ii.nazwa='Seminarium' THEN
        SELECT ID_CHARAKTER FROM CHARAKTER INTO tmp_kod WHERE NAZWA='Laboratoria';
        UPDATE zajecia SET id_charakter=tmp_kod WHERE CURRENT OF my_cursor;
      WHEN ii.nazwa='Æwiczenia' THEN
        SELECT ID_CHARAKTER FROM CHARAKTER INTO tmp_kod WHERE NAZWA='Seminarium';
        UPDATE zajecia SET id_charakter=tmp_kod WHERE CURRENT OF my_cursor;
    END CASE;
  END LOOP;
END;


--zad7
DECLARE
  TYPE typ IS RECORD
  (
    NAZWA VARCHAR2(40),
    WYKL VARCHAR2(50)
  );
  
  rec typ;
  
  CURSOR cur IS
    SELECT DISTINCT 
      PRZEDMIOT.NAZWA, 
      WYKLADOWCA.IMIE || ' ' ||WYKLADOWCA.NAZWISKO AS WYKL
    FROM ZAJECIA, OCENA, STUDENT, GRUPA, WYKLADOWCA, PRZEDMIOT
    WHERE 
      ZAJECIA.ID_GRUPA=GRUPA.ID_GRUPA
      AND STUDENT.ID_GRUPA=GRUPA.ID_GRUPA
      AND STUDENT.ID_STUDENT=OCENA.ID_STUDENT
      AND OCENA.ID_ZAJECIA=ZAJECIA.ID_ZAJECIA
      AND WYKLADOWCA.ID_WYKLADOWCA=ZAJECIA.ID_WYKLADOWCA
      AND PRZEDMIOT.ID_PRZEDMIOT=ZAJECIA.ID_PRZEDMIOT
      
      AND OCENA.OCENA<3;
BEGIN
  OPEN cur;
    LOOP
      FETCH cur INTO rec;
      DBMS_OUTPUT.PUT_LINE(rec.nazwa||' '||rec.wykl);
      EXIT WHEN cur%NOTFOUND;
      EXIT WHEN cur%ROWCOUNT>2;
    END LOOP;
  CLOSE cur;
END;

--zad8





