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
  --to nie bo ma by? wg. polecenia wykorzystane fetch
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
    SELECT id_zajecia
    FROM zajecia
    JOIN przedmiot ON zajecia.id_przedmiot=przedmiot.id_przedmiot
    JOIN sala ON zajecia.id_sala=sala.id_sala
    JOIN budynek ON sala.id_budynek=budynek.id_budynek
    JOIN grupa ON zajecia.id_grupa=grupa.id_grupa
    JOIN student ON student.id_grupa=grupa.id_grupa
    WHERE sala.kodsali=input_kodsali
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
--z blizej nieznanych ppowodow nie dziala update a na kodzie lukasza wykomentowanym (ake blednym) dziala
DECLARE
  przedmiot_nazwa2 VARCHAR2(40);
  id_stud STUDENT.ID_STUDENT%type;
  counter NUMBER(2):=0;
  too_high_rating EXCEPTION;
  
  CURSOR my_cursor(przedmiot_nazwa varchar2) IS
    /*SELECT O.OCENA FROM OCENA O
	  JOIN ZAJECIA ON ZAJECIA.ID_ZAJECIA=O.ID_ZAJECIA
	  JOIN PRZEDMIOT ON PRZEDMIOT.ID_PRZEDMIOT=ZAJECIA.ID_PRZEDMIOT
	  WHERE PRZEDMIOT.NAZWA=przedmiot_nazwa
	  AND O.OCENA=
    (
      SELECT MIN(X.OCENA) 
      FROM OCENA X 
      WHERE X.ID_OCENA=O.ID_OCENA
    )
	  ORDER BY O.OCENA ASC FOR UPDATE;*/
    SELECT OCENA.ocena
    FROM ZAJECIA, OCENA, STUDENT, GRUPA, PRZEDMIOT pp
    WHERE 
      ZAJECIA.ID_GRUPA=GRUPA.ID_GRUPA
      AND STUDENT.ID_GRUPA=GRUPA.ID_GRUPA
      AND STUDENT.ID_STUDENT=OCENA.ID_STUDENT
      AND OCENA.ID_ZAJECIA=ZAJECIA.ID_ZAJECIA
      AND pp.ID_PRZEDMIOT=ZAJECIA.ID_PRZEDMIOT
      AND pp.nazwa=przedmiot_nazwa
      and OCENA.OCENA=
      (
        select min(ocena.ocena)
        from ocena, przedmiot x, zajecia
        where ocena.id_zajecia=zajecia.id_zajecia
        and x.id_przedmiot=pp.id_przedmiot
      )
    ORDER BY OCENA ASC
    FOR UPDATE;
  
BEGIN
  przedmiot_nazwa2:='&test';

  FOR kk IN my_cursor(przedmiot_nazwa2) LOOP
    IF(kk.ocena>=4.5) THEN
      RAISE too_high_rating;
    END IF;
    UPDATE ocena set ocena=ocena+0.5 where current of my_cursor;
    dbms_output.put_line(SQL%ROWCOUNT);
    dbms_output.put_line('ocena: ' || kk.ocena);
    counter:=counter+1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('przedmiot: '|| przedmiot_nazwa2);
  DBMS_OUTPUT.PUT_LINE('zmiany: '||to_char(counter));
  
EXCEPTION
  WHEN too_high_rating THEN
    DBMS_OUTPUT.PUT_LINE('za duza ocena! ');
    RETURN;
END;


--ZAD6
ACCEPT INPUT prompt 'wprowadz grupe';
DECLARE
  grupa_nazwa2 varchar2(30);
  
  CURSOR my_cursor(grupa_nazwa varchar2) IS
    SELECT charakter.nazwa 
    FROM ZAJECIA
    LEFT JOIN GRUPA USING(ID_GRUPA)
    LEFT JOIN CHARAKTER USING(ID_CHARAKTER)
    WHERE GRUPA.NAZWA=grupa_nazwa
    FOR UPDATE;
BEGIN
  grupa_nazwa2:='&input';
  FOR ii IN my_cursor(grupa_nazwa2) LOOP
    CASE
      WHEN ii.nazwa='Laboratoria' THEN
        UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Wyk³ady') WHERE CURRENT OF my_cursor;
      WHEN ii.nazwa='Wyk³ady' THEN
        UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Æwiczenia') WHERE CURRENT OF my_cursor;
      WHEN ii.nazwa='Seminarium' THEN
        UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Laboratoria') WHERE CURRENT OF my_cursor;
      WHEN ii.nazwa='Æwiczenia' THEN
        UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Seminarium') WHERE CURRENT OF my_cursor;
      ELSE
        NULL;
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
--nie dziala
DECLARE
  przedmiot_nazwa2 VARCHAR2(50);
  
  CURSOR my_cursor(przedmiot_nazwa varchar2) IS
    SELECT zajecia.id_zajecia 
    FROM ZAJECIA
    LEFT JOIN PRZEDMIOT USING(ID_PRZEDMIOT)
    WHERE PRZEDMIOT.NAZWA=przedmiot_nazwa
    FOR UPDATE;
    
  /*CURSOR my_cursor2 IS
    SELECT zajecia.id_zajecia
    FROM ZAJECIA;*/
BEGIN
  przedmiot_nazwa2:='&input';
  UPDATE ocena.ocena SET ocena=ocena+0.5 WHERE ocena<=4.5;
  
  /*FOR jj IN my_cursor2 LOOP
    UPDATE ocena
    SET ocena.ocena=ocena.ocena+0.5 
    WHERE ocena.ocena<=4
    AND ID_ZAJECIA=my_cursor2.id_zajecia
    WHERE CURRENT OF my_cursor2;
  END LOOP;*/
  
  FOR ii IN my_cursor(przedmiot_nazwa2) LOOP
    UPDATE ocena
    SET ocena.ocena=ocena.ocena+1 
    WHERE ocena.ocena<=4
    AND ID_ZAJECIA=my_cursor.id_zajecia
    WHERE CURRENT OF my_cursor;
  END LOOP;
END;




